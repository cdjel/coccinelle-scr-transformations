@history_map@
declarer name __uint, __type;
attribute name SEC;
@@

struct{
    ...
} port_state;
+ struct {
+    __uint(type, BPF_MAP_TYPE_PERCPU_ARRAY);
+    __type(key, u32);
+    __type(value, int); 
+    __uint(max_entries, 1);
+ } history_map SEC(".maps");

