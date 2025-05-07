@@
@@
- if (value->state == CLOSED_0 && dport == PORT_1) {
-       value->state = CLOSED_1;
-    } else if (value->state == CLOSED_1 && dport == PORT_2) {
-        value->state = CLOSED_2;
-    } else if (value->state == CLOSED_2 && dport == PORT_3) {
-        value->state = OPEN;
-    } else {
-        value->state = CLOSED_0; 
-    }
...
- if (value->state == OPEN){
-        rc = XDP_PASS;
-    } 
+ bpf_map_update_elem(&port_state, &state_id, value, BPF_ANY);
+
+ if (value->state == OPEN) {
+     return XDP_PASS;
+ } else {
+     return XDP_DROP;
+ }


@@
@@
struct array_elem{
    u32 state;
};
+ static inline u32 get_new_state(u32 state, u16 dport) {
+  if (state == CLOSED_0 && dport == PORT_1) {
+    state = CLOSED_1;
+  } else if (state == CLOSED_1 && dport == PORT_2) {
+    state = CLOSED_2;
+  } else if (state == CLOSED_2 && dport == PORT_3) {
+    state = OPEN;
+  } else {
+    state = CLOSED_0;
+  }
+  return state;
+ }
