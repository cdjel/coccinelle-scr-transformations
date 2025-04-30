@ao_case@
expression value, bytes, bytes_before;
@@ 
- bytes_before = __sync_fetch_and_add(value, bytes);
+ bytes_before = *value;  

@change_hash_map depends on ao_case@
attribute name SEC;
declarer name __uint, __type;
metavariable map_name;
@@
struct{
    ...
- __uint(type, BPF_MAP_TYPE_HASH);
+ __uint(type, BPF_MAP_TYPE_PERCPU_HASH);
    ...
} map_name SEC(".maps");
