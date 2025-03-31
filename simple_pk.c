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

struct array_elem {
    u32 state;
};
struct packet {
    struct ethhdr eth;
    struct iphdr ip4;
    struct tcphdr tp;
}
struct {
    __uint(type, BPF_MAP_TYPE_ARRAY);
    __type(key, u32);
    __type(value, struct array_elem);
    __uint(max_entries, 1);
} port_state SEC(".maps");
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