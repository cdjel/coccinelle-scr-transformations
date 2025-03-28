@@
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