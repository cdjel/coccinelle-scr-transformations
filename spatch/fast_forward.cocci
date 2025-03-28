@num_meta@
@@
#define PORT_3 102
+ #define NUM_META 10

@depends on num_meta@
attribute name SEC;
@@
struct {
    ...
} history_map SEC(".maps");

+ void fast_forward_state(void *data, int index) {
+    for (int j = 0; j < NUM_META; j++) {
+        int i = (index + j) % NUM_META; // Ring buffer 
+        struct metadata *meta = data + i * sizeof(struct metadata);

+        if (meta->l3proto != htons(ETH_P_IP) || meta->l4proto != IPPROTO_TCP)
+            continue;

+        u32 state_id = 0; 
+        struct array_elem *value = bpf_map_lookup_elem(&port_state, &state_id);
+        if (!value) {
+            struct array_elem init_state = { .state = CLOSED_0 }; 
+            bpf_map_update_elem(&port_state, &state_id, &init_state, BPF_ANY);
+            value = &init_state;
+        }
+        value->state = get_new_state(value->state, meta->dport);
+        bpf_map_update_elem(&port_state, &state_id, value, BPF_ANY);
+    }
+ }
