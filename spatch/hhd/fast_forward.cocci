@num_meta@
@@
#define PORT_3 102
+ #define NUM_META 10

@depends on num_meta@
attribute name SEC;
declarer name __uint;
metavariable map_name, elem;
@@
struct {
    __uint(...);
    ...
} map_name SEC(".maps");

+ void fast_forward_state(void *data, int index, struct flow_key *key) {
+    for (int j = 0; j < NUM_META; j++) {
+        int i = (index + j) % NUM_META; // Ring buffer 
+        struct metadata *meta = data + i * sizeof(struct metadata);

+        if (meta->l3proto != htons(ETH_P_IP) || meta->l4proto != IPPROTO_TCP)
+            continue;
+        u64 *value = bpf_map_lookup_elem(&map_name, key);
+        if (!value) {
+            u64 bytes = meta->packet_length
+            bpf_map_update_elem(&map_name, key, &bytes, BPF_ANY);
+        }
+        u64 new_bytes = *value + meta->packet_length;
+        bpf_map_update_elem(&map_name, key, &new_bytes, BPF_ANY);
+    }
+ }


@depends on num_meta@
metavariable flow, map, data;
@@
+ int cpu = bpf_get_smp_processor_id();
+ int index = cpu % NUM_META;
+ fast_forward_state(data, index, &flow);
value = bpf_map_lookup_elem(&map, &flow);