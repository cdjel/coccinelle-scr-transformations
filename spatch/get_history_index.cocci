@@
@@

+ int *history_index = bpf_map_lookup_elem(&history_map, &state_id);
+ if (!history_index) {
+     int init_index = 0;
+     bpf_map_update_elem(&history_map, &state_id, &init_index, BPF_ANY);
+     history_index = bpf_map_lookup_elem(&history_map, &state_id);
+ }
+
+ if (history_index) {
+     fast_forward_state(data, *history_index);
+     int new_index = (*history_index + 1) % NUM_META;
+     bpf_map_update_elem(&history_map, &state_id, &new_index, BPF_ANY);
+ }
value = bpf_map_lookup_elem(&port_state, &state_id);
