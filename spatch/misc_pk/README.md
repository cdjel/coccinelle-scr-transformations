# SCR-BPF Transformations for Port-Knocking (Overview)
- Some programs that we explored to try to make transofrmations to be SCR-aware are port-knocking viles (v1 from sample files from: https://github.com/smartnic/bpf-profile ), and another is a more simplified implementation. 
- These were the first programs to be explored, so some other spatches created later on with token bucket and hhd can be appied here, such as detecting locks as an indication that state is shared. 

## Outline
- semantic patches: under the directory spatch/misc_pk (which is where this README is located)
- src: source files to make transformations from: simple_pk.c, pk_v1.c 
- mod: generated files (aka the output after a transformation/spatch is applied)
- ---> NOTE: not all of these MOD (generated) files reflect a complete or final SCR-aware program, but rather to demonstrate individual transformation steps that were attempted in the process. 

### SRC file: simple_pk.c, pk_v1.c 
- Two port-knocking files: simple_pk.c, pk_v1.c
- pk_v1.c is taken from bpf-profile sample files. Includes per-source IP state, shared state with hash map, and locking (spin locks)
- simple_pk.c is a simplfied implementation of port-knocking, as it uses a map array type with a fixed state (state_id), (unlike per-source IP state from pk_v1.c), and no locking (since there's only one fixed state)

### Spatches
1. revised_change_map_locks.cocci: replaces the BPF map type from type HASH to PERCPU_HASH. Based on the assumption that an indication of shared state could be locking, so the rule to change map type depends on if locking is detected.
- ---> NOTE: making this transformation for the map makes the map sharded across cores 
- ---> NOTE: a generalized spatch including detection for other rules such as atomic operations are in the dir spatch/hhd
2. metadata.cocci: adds a metadata struct that stores flow metadata, last_time (a field we want to track for state), and src & dst IPs & protocol info for filtering in fast-forward, with the anchor being a struct with a bpf map. This is needed for fast-forwarding, as we need to catch-up a core with the effects of past packets 

3. metadata_gen2.cocci: attempts to generalize metadata.cocci, while also experimenting with the keyword "depends on" feature. 

4. fast_forward.cocci: adds the fast-forwarding function to help catch-up state with the effects of previous packets that may have been missed, using that metadata history. 

5. state_transition: non-SCR-aware related. Just transfers the state transition logic (into a helper function / restructuring).

6. remove_spin_lock.cocci: removes spin locks both in struct and calls in code (follows format of lock & unlock). 

### MOD (generated output files) from mod/pk_v1_mod & mod/simplified_pk_mod:
- From simple_pk.c:
1. mod/simplified_pk_mod/change_map.c: map type changed to PERCPU ARRAY. Makes state from shared to sharded.
2. mod/simplified_pk_mod/state_transition.c: Applied with state_transition.cocci to modularize the state (restructure into a helper function, not SCR-aware related).
3. mod/pk_v1_mod/v1_state_trans.c: applied the state_transition.cocci to modularize the state transition logic. Non-SCR-aware related.
4. mod/pk_v1_mod/v1_scr.c: all spatches applied to attempt to make a SCR-aware program. 
5. v1_remove_lock.c: applied remove_spin_lock.cocci to remove the spin locks.
6. v1_metadata.c: applied metadata spatches (either the generalized or initial spatch)
7. v1_fast_forward.c: applied fast_forward.cocci
- NOTE: the final transformed scr-aware version of these files are still ongoing. Due to variable mismatches / partially applied SCR features, some transformations are not completely aligned yet. 
- ---> Therefore, these spatches and outputs are part of an ongoing exploration of using Coccinelle. 



