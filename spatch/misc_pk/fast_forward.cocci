@num_meta@
@@
#define PORT_3 102
+ #define NUM_META 10

@depends on num_meta@
attribute name SEC;
@@
struct {
    ...
} port_state SEC(".maps");

+ void fast_forward_state(void *data, int index, u32 srcip) {
+    for (int j = 0; j < NUM_META; j++) {
+        int i = (index + j) % NUM_META; // Ring buffer 
+        struct metadata *meta = data + i * sizeof(struct metadata);

+        if (meta->l3proto != htons(ETH_P_IP) || meta->l4proto != IPPROTO_TCP)
+            continue;
+        struct array_elem *value = bpf_map_lookup_elem(&port_state, &srcip);
+        if (!value) {
+            struct array_elem init_state = { .state = CLOSED_0 }; 
+            bpf_map_update_elem(&port_state, &srcip, &init_state, BPF_ANY);
+            continue;
+        }
+        value->state = get_new_state(value->state, meta->dport);
+        bpf_map_update_elem(&port_state, &srcip, value, BPF_ANY);
+    }
+ }


@depends on num_meta@
@@
src_ip = iph->saddr;
+ int cpu = bpf_get_smp_processor_id();
+ int index = cpu % NUM_META;
+ fast_forward_state(data, index, src_ip);