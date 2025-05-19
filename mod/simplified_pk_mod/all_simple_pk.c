#define KBUILD_MODNAME "foo"
#include <uapi/linux/bpf.h>
#include <linux/types.h>
#include <linux/if_ether.h>
#include <linux/in.h> 
#include <linux/ip.h>
#include <linux/udp.h>
#include <linux/tcp.h>
#include <bpf/bpf_helpers.h>
// #include "xdp_utils.h"
// single cpu core 
enum state {
    CLOSED_0 = 0,
    CLOSED_1,
    CLOSED_2,
    OPEN,
};
// removed SPORT_MIN/MAX
#define PORT_1 100
#define PORT_2 101
#define PORT_3 102
#define NUM_META 10

struct array_elem {
    u32 state;
};
struct metadata {
    int l3proto;
    int l4proto;
    u32 srcip;
    u16 dport;
};
struct packet {
    struct ethhdr eth;
    struct iphdr ip4;
    struct tcphdr tp;
}
/*
 * key: state_id (global state)
 * value: state
 */
struct {
    __uint(type, BPF_MAP_TYPE_PERCPU_HASH);
    __type(key, u32);
    __type(value, struct array_elem);
    __uint(max_entries, 1);
} port_state SEC(".maps");

void fast_forward_state(void *data, int index, u32 srcip)
{
    for(int j = 0;j < NUM_META;j++) {
        int i = (index + j) % NUM_META; // Ring buffer 
        struct metadata *meta = data + i * sizeof(struct metadata);
        if (meta->l3proto != htons(ETH_P_IP) || meta->l4proto != IPPROTO_TCP)
            continue;
        struct array_elem *value = bpf_map_lookup_elem(&port_state, &srcip);
        if (!value) {
            struct array_elem init_state = {
                .state = CLOSED_0
                };
            bpf_map_update_elem(&port_state, &srcip, &init_state, BPF_ANY);
            continue;
        }
        value->state = get_new_state(value->state, meta->dport);
        bpf_map_update_elem(&port_state, &srcip, value, BPF_ANY);
    }
}
//removed helper functions for ipv4 & udp
SEC("xdp_portknock")
int xdp_prog(struct xdp_md *ctx) {
    void *data_end = (void *)(long)ctx->data_end;
    void *data = (void *)(long)ctx->data;
    struct packet *pkt = (struct packet *)data;
    struct array_elem *value;
    int rc = XDP_DROP;
    u16 dport;
    int state_id = 0;

    if ((void *)pkt + sizeof(*pkt) > data_end) // avoid reading beyond end of packet 
        return rc;
    
    if (pkt->eth.h_proto != htons(ETH_P_IP))
        return rc;
    
    if (pkt->ip4.protocol != IPPROTO_TCP){
        return XDP_DROP;
    }
    dport = ntohs(pkt->tp.dest);

    value = bpf_map_lookup_elem(&port_state, &state_id);
    if (!value){
        return rc;
    }
    if (value->state == OPEN){
        rc = XDP_PASS;
    } 
    // state transition 
    if (value->state == CLOSED_0 && dport == PORT_1) {
        value->state = CLOSED_1;
    } else if (value->state == CLOSED_1 && dport == PORT_2) {
        value->state = CLOSED_2;
    } else if (value->state == CLOSED_2 && dport == PORT_3) {
        value->state = OPEN;
    } else {
        value->state = CLOSED_0; 
    }

    return rc; // was XDP_TX;
}

char _license[] SEC("license") = "GPL";