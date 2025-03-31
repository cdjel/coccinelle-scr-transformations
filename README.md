# SCR-BPF Transformations

This repo provides an overview on how to make eBPF programs SCR-aware using semantic patches with Coccinelle.

## What is Coccinelle?
https://coccinelle.gitlabpages.inria.fr/website/ 
- Coccinelle is a program matching and transformation engine 

- Coccinelle uses semantic patches, written in the Semantic Patch Language (SmPL)
* -> Semantic patches have three main parts:
* -> Rule name, metavariable
* -> context/code patterns to match the code you are trying to transform/modify
* ---> the transformation (-/+)

## What do you mean by SCR-aware? What is State-Compute Replication?
- SCR-aware stands for State-Compute Replication Aware. What we mean by this is have programs have each core independently computing states when processing packets

- State-Compute Replication is a technique that states that instead of cores sharing state, each core will update the state on its own, using packet history/fast-forwarding.

- What makes a program SCR-aware follows these three main concepts:
-> Per-core state (each core has own view of state)
-> per-packet metadata (helps update state on each core, needed for fast-forwarding)
-> fast-forwarding using packet history (lets each core "catch up" to the correct state)

- We are making SCR-aware transformations because eBPF programs can be written for single core execution or programs may use shared maps. So, we can create transformations where we can, for example, remove locks, replace shared state with per-core (i.e. BPF maps), etc.
# Overview:


# Structure of Repo
- spatch/: examples of semantic patches (spatches)
- mod/: examples of transformed programs (after a spatch was applied)
- src/: example source files to transform

# Installing and Using Coccinelle
```bash
git clone https://github.com/coccinelle/coccinelle.git
cd coccinelle
./autogen
./configure
make 
sudo make install
```


## Semantic Patch Language (SmPL)
- A semantic patch (.cocci) can have many rules 
- Coccinelle is context dependant. What that means is that we need to provide 
- A rule can look like this:
@name_of_rule@
@@
- int var = 0
+ int var = 1

-> As you can see above, the name of the rule can be anything but it needs to be without spaces. Rules don't need to have names.
--> Names of rules are necessary if you want to specify dependencies between rules (see below on advanced keywords)


### Advanced Keywords
- We can also specify keywords for rules
- For example, we can have a rule execute only if another rule had succesfully executed. We use "depends on"
@num_meta@
@@
#define PORT_3 102
+ #define NUM_META 10

@depends on num_meta@
@@
src_ip = iph->saddr;
+ int index = cpu % NUM_META;

--> Above: the second rule depends on the rule 'num_meta.' If num_meta is successful, then the second rule will execute.

## How to apply a semantic patch
- General format:
spatch --sp-file spatchfile.cocci program.c 
--> As seen above, we apply a spatch called spatchfile.cocci onto program.c

- You can also apply a patch on a directory:
spatch --sp-file spatchfile.cocci --dir directory

- We can also output the transformation by:
spatch --sp-file spatchfile.cocci program.c -o output.c

- We could debug a failed transformation further by:
spatch --sp-file spatchfile.cocci program.c --debug 