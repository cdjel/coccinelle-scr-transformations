@@
@@
struct array_elem{
    u32 state;
};

+ struct metadata {
+   int l3proto;
+   int l4proto;
+   u32 srcip;
+   u16 dport;
+ }; 