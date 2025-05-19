@replacement@
declarer name __uint;
attribute name SEC;
@@
 struct
 {
 ...
 __uint(type,
-       BPF_MAP_TYPE_ARRAY
+       BPF_MAP_TYPE_PERCPU_HASH
       );
 ...
 } port_state;