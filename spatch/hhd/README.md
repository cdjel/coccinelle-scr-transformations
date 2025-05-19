# SCR-BPF Transformations for HHD (Overview)
- One program that we explored to try to make transofrmations to be SCR-aware is this HHD file (v1 from sample files from: https://github.com/smartnic/bpf-profile )

## Outline
- semantic patches: under the directory spatch/hhd (which is where this README is located)
- src: source files to make transformations from: hhd_v1.c
- mod: generated files (aka the output after a transformation/spatch is applied)
- ---> NOTE: not all of these MOD (generated) files reflect a complete or final SCR-aware program, but rather to demonstrate individual transformation steps that were attempted in the process. 

### SRC file: hhd_v1.c
- Heavy hitter detection program (v1 from the bpf-profile sample files) that originally had used a shared hash map and atomic operations (by which tracks per-flow byte counts)

### Spatches
1. change_map_ao.cocci: Detects an atomic operation (__sync_fetch_and_add) and changes bpf map from type HASH to PERCPU_HASH. This is made under the assumption that this atomic operation is an indication that state is shared, and therefore would need to transform the map type. 
- ---> NOTE: making this transformation for the map makes the map sharded across cores 
2. change_map_locks.cocci: This was technically written for a program like the token bucket (tb_v1.c), where we detect spin locks and perform the same transformation as change_map_ao.cocci of changing map type HASH to PERCPU_HASH, based on the assumption that locks are also an indicator of shared state.
3. gen_change_map.cocci: first attempt of a generalized spatch for changing map types based on either cases of locks or atomic operations being an indicator of shared state.
4. gen_change_map_atomics.cocci: extended atomic operations that could be detected. Showcases how we can use disjunction to match different patterns in the transformation. 
5. metadata.cocci: adds a metadata struct that stores flow metadata, packet length (a field we want to track for state), and src & dst IPs & protocol info for filtering in fast-forward, with the anchor being a struct with a bpf map. This is needed for fast-forwarding, as we need to catch-up a core with the effects of past packets 
6. fast_forward.cocci: adds the fast-forwarding function to help catch-up state with the effects of previous packets that may have been missed, using that metadata history. Updates state before the current lookup.

### MOD (generated output files)
1. gen_change_map.c: generated output .c after applying a generalized change_map spatch (gen_change_map.cocci or gen_change_map_atomics.cocci for example)
2. gen_change_map_tb.c: This is actually from the token bucket file (tb_v1.c), but had applied that generalized change_map patch as mentioned above to see if it would work for both the hhd and token bucket files.
3. gen_change_map_hhd_atomics.c: transforming the hhd_v1.c with the extended generalized spatch (gen_change_map_atomics.cocci)
4. metadata.c: generated output after applying metadata.cocci
- NOTE: the final transformed scr-aware version of hhd_v1.c is still ongoing. Due to variable mismatches / partially applied SCR features, some transformations are not completely aligned yet. 
- ---> Therefore, these spatches and outputs are part of an ongoing exploration of using Coccinelle. 

### Order / Limitations
- applied gen_change_map_atomics.cocci, metadata.cocci, fast_forward.cocci
- Limitations:
- --> no bpf map is defined for metadata / ringbuffer 
- --> currently does two separate updates per packet (after fast_forward_state, main code still adds current packet's byte count) -> needs to be revised so that all byte count updates happen in once place (no duplicates)
