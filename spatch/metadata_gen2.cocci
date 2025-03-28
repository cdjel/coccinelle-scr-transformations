@header_exists@
@@
#include <bpf/bpf_helpersss.h>

@depends on header_exists@
@@
struct array_elem{
    ...
};
+ struct metadata {
+   int l3proto;
+   int l4proto;
+   u32 srcip;
+   u16 dport;
+ }; 
