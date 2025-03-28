@replacement4@
attribute name SEC;
declarer name __uint;
constant char[] maps;
@@
 struct
 {
 ...
 __uint(type,
-       BPF_MAP_TYPE_ARRAY
+       BPF_MAP_TYPE_PERCPU_ARRAY
       );
 ...
 } port_state SEC(".maps");