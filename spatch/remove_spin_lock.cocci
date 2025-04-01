@@
expression E;
@@
- bpf_spin_lock(E);
...
- bpf_spin_unlock(E);

@@
metavariable name;
@@
struct name {
    ...
- struct bpf_spin_lock lock;
};


