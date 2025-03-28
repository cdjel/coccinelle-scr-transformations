@@
expression E;
@@
- bpf_spin_lock(E);
...
- bpf_spin_unlock(E);

@@
@@
struct array_elem {
    ...
- struct bpf_spin_lock lock;
};