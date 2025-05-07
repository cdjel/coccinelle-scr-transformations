@@
attribute name SEC; 
declarer name __uint;
metavariable map_name;
@@
 struct {
   __uint(...);
   ...
 } map_name SEC(".maps");

+ struct metadata {
+   int l3proto;
+   int l4proto;
+   u32 srcip;
+   u32 dstip;
+   u16 src_port;
+   u16 dst_port;
+   u8 protocol;
+   u64 last_time;
+ }; 

 