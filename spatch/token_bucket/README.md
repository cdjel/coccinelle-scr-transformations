# SCR-BPF Transformations for Token Bucket (Overview)
- A program that we explored to try to make transofrmations to be SCR-aware is this Token Bucket file (v1 from sample files from: https://github.com/smartnic/bpf-profile )

## Outline
- semantic patches: under the directory spatch/token_bucket (which is where this README is located)
- src: source files to make transformations from: tb_v1.c
- mod: generated files (aka the output after a transformation/spatch is applied)
- ---> NOTE: not all of these MOD (generated) files reflect a complete or final SCR-aware program, but rather to demonstrate individual transformation steps that were attempted in the process. 

### SRC file: tb_v1.c
- Token Bucket program (v1 from the bpf-profile sample files) that originally had used a shared hash map (by which tracks per-flow with tokens) and locking (spin locks)

### Spatches
1. revised_change_map_locks.cocci: replaces the BPF map type from type HASH to PERCPU_HASH. Based on the assumption that an indication of shared state could be locking, so the rule to change map type depends on if locking is detected.
- ---> NOTE: making this transformation for the map makes the map sharded across cores 
- ---> NOTE: a generalized spatch including detection for other rules such as atomic operations are in the dir spatch/hhd
2. change_map_locks.cocci: 

3. metadata.cocci: adds a metadata struct that stores flow metadata, last_time (a field we want to track for state), and src & dst IPs & protocol info for filtering in fast-forward, with the anchor being a struct with a bpf map. This is needed for fast-forwarding, as we need to catch-up a core with the effects of past packets 

4. fast_forward.cocci: adds the fast-forwarding function to help catch-up state with the effects of previous packets that may have been missed, using that metadata history. Updates state before the current lookup.

### MOD (generated output files)
1. gen_change_map.c: generated output .c after applying a generalized change_map spatch (gen_change_map.cocci or gen_change_map_atomics.cocci for example)
2. gen_change_map_tb.c: This is actually from the token bucket file (tb_v1.c), but had applied that generalized change_map patch as mentioned above to see if it would work for both the hhd and token bucket files.
3. gen_change_map_hhd_atomics.c: transforming the hhd_v1.c with the extended generalized spatch (gen_change_map_atomics.cocci)
4. metadata.c: generated output after applying metadata.cocci
- NOTE: the final transformed scr-aware version of tb_v1.c is still ongoing. Due to variable mismatches / partially applied SCR features, some transformations are not completely aligned yet. 
- ---> Therefore, these spatches and outputs are part of an ongoing exploration of using Coccinelle. 


