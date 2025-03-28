#define KBUILD_MODNAME "foo"
#include <uapi/linux/bpf.h>
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

struct {
    __uint(type, BPF_MAP_TYPE_PERCPU_ARRAY);
    __type(key, u32);
    __type(value, struct array_elem);
    __uint(max_entries, 1);
} port_state SEC(".maps");
//removed helper functions for ipv4 & udp
SEC("xdp_portknock")
int xdp_prog(struct xdp_md *ctx) {
    void *data_end = (void *)(long)ctx->data_end;
    void *data = (void *)(long)ctx->data;
    struct ethhdr *eth = data;
    struct array_elem *value;
    u16 h_proto;
    u64 nh_off;
    u16 dport;
    int rc = XDP_DROP;
    int state_id = 0;
    // ipproto
    
    nh_off = sizeof(*eth);
    if (data + nh_off > data_end)
        return rc;
    h_proto = eth->h_proto;
    if (h_proto != htons(ETH_P_IP))
        return rc;
    
    struct iphdr *iph = data + sizeof(*eth);
    if ((void *)iph + sizeof(*iph) > data_end)
        return XDP_DROP;
    
    if (iph->protocol != IPPROTO_TCP){
        return XDP_DROP;
    }
    struct tcphdr *tcp = (void *)iph + sizeof(*iph);
    if ((void *)tcp + sizeof(*tcp) > data_end)
        return XDP_DROP;
    dport = ntohs(tcp->dest);

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