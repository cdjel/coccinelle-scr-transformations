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
+   u32 l3proto;
+   u32 l4proto;
+   u16 srcip;
+   u16 dport;
+   u8 protocol;
+ }; 