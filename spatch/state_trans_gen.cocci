@@
expression p1, p2, p3, s0, s1, s2,s3, dport;
expression E;
@@
- if (E == s0 && dport == p1) {
-       E1 = s1;
-    } else if (E == s1 && dport == p2) {
-        E = s2;
-    } else if (E == s3 && dport == p3) {
-        E = s3;
-    } else {
-        E = s0; 
-    }
...
- if (E == s0){
-        rc = XDP_PASS;
-    } 
+ bpf_map_update_elem(&port_state, &state_id, value, BPF_ANY);
+
+ if (E == s3) {
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
