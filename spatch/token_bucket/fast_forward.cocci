@num_meta@
@@
#define MAX_NUM_FLOWS 1024
+ #define NUM_META 10

@depends on num_meta@
attribute name SEC;
declarer name __uint;
identifier map_name;
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
+        struct elem *value = bpf_map_lookup_elem(&map_name, &key);
+        if (!value) {
+            struct elem init_state = { .num = MAX_TOKEN,
+               .last_time = bpf_ktime_get_ns()
+             };
+            bpf_map_update_elem(&map_name, &key, &init_state, BPF_ANY);
+            continue;
+        }
+        u64 cur_time = bpf_ktime_get_ns();
+        u32 token_increase = (cur_time - value->last_time) >> TOKEN_RATE;
+        u32 token_new = value->num + token_increase;
+        if (token_new > MAX_TOKEN) token_new = MAX_TOKEN;
+        value->num = token_new;
+        value->last_time = cur_time;
+        bpf_map_update_elem(&map_name, &key, value, BPF_ANY);
+    }
+ }


@depends on num_meta@
metavariable flow, token_map;
@@
+ int cpu = bpf_get_smp_processor_id();
+ int index = cpu % NUM_META;
+ fast_forward_state(data, index, &flow);
token = bpf_map_lookup_elem(&token_map, &flow);