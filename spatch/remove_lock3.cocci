@@
expression e;
identifier fld;
statement S1, S2;
@@

if (!e) S1
else {
    ...
-  bpf_spin_lock(&e->fld);
   ...
-  bpf_spin_unlock(&e->fld);
   S2
}
