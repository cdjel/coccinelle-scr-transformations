@ao_case@
expression p, q, var;
@@ 
- var = __sync_fetch_and_add(p, q);
+ var = *p;  

@lock_case@
metavariable name;
@@
struct name {
    ...
- struct bpf_spin_lock lock;
}; 

@lock_case2@
expression e;
identifier fld;
statement S1, S2;
@@
-  bpf_spin_lock(&e->fld);
   ...
-  bpf_spin_unlock(&e->fld);
   
@change_hash_map depends on (lock_case&&lock_case2) || ao_case @
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
