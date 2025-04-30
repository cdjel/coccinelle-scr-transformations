@struct_key_case@
attribute name SEC;
declarer name __uint, __type;
metavariable var, map_name;
@@

struct {
    ...
    __uint(type, BPF_MAP_TYPE_HASH);
    __type(key, struct var);
    ...
} map_name SEC(".maps");


@change_hash_map depends on struct_key_case@
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
