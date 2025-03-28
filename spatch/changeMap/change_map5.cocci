@replacement3@
attribute name SEC;
declarer name __uint;
@@
 struct
 {
 ...
- __uint(type, BPF_MAP_TYPE_ARRAY);
+ __uint(type,   BPF_MAP_TYPE_PERCPU_ARRAY);
 ...
 } port_state SEC(".maps");