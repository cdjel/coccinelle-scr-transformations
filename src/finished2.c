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

static inline u32 get_new_state(u32 state, u16 dport)
{
    if (state == CLOSED_0 && dport == PORT_1) {
        state = CLOSED_1;
    }
    else
        if (state == CLOSED_1 && dport == PORT_2) {
            state = CLOSED_2;
        }
    else
        if (state == CLOSED_2 && dport == PORT_3) {
            state = OPEN;
        }
    else {
        state = CLOSED_0;
    }
    return state;
}

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
struct {
    __uint(type, BPF_MAP_TYPE_PERCPU_ARRAY);
    __type(key, u32);
    __type(value, struct array_elem);
    __uint(max_entries, 1);
} port_state SEC(".maps");
struct {
    __uint(type, BPF_MAP_TYPE_PERCPU_ARRAY);
    __type(key, u32);
    __type(value, int);
    __uint(max_entries, 1);
} history_map SEC(".maps");

void fast_forward_state(void *data, int index)
{
    for(int j = 0;j < NUM_META;j++) {
        int i = (index + j) % NUM_META; // Ring buffer 
        struct metadata *meta = data + i * sizeof(struct metadata);
        if (meta->l3proto != htons(ETH_P_IP) || meta->l4proto != IPPROTO_TCP)
            continue;
        u32 state_id = 0;
        struct array_elem *value = bpf_map_lookup_elem(&port_state, &state_id);
        if (!value) {
            struct array_elem init_state = {
                .state = CLOSED_0
                };
            bpf_map_update_elem(&port_state, &state_id, &init_state, BPF_ANY);
            value = &init_state;
        }
        value->state = get_new_state(value->state, meta->dport);
        bpf_map_update_elem(&port_state, &state_id, value, BPF_ANY);
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

    int *history_index = bpf_map_lookup_elem(&history_map, &state_id);
    if (!history_index) {
        int init_index = 0;
        bpf_map_update_elem(&history_map, &state_id, &init_index, BPF_ANY);
        history_index = bpf_map_lookup_elem(&history_map, &state_id);
    }

    if (history_index) {
        fast_forward_state(data, *history_index);
        int new_index = (*history_index + 1) % NUM_META;
        bpf_map_update_elem(&history_map, &state_id, &new_index, BPF_ANY);
    }
    value = bpf_map_lookup_elem(&port_state, &state_id);
    if (!value){
        return rc;
    }
    value->state = get_new_state(value->state, dport);
    bpf_map_update_elem(&port_state, &state_id, value, BPF_ANY);
    if (value->state == OPEN) {
        return XDP_PASS;
    } else {
        return XDP_DROP;
    }
        
}

char _license[] SEC("license") = "GPL";