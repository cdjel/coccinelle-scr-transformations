# SCR-BPF Transformations: multiple spatch variants example
- Coccinelle is context dependent. We don't need to define all of our metavariables, for example, but it needs to be able to match something in the transformation we want to make. 

- Coccinelle does its best to automatically infer how to parse certain elemets, especially when the code is simpler or follow common patterns, essentially what Coccinelle can already understand based on its own parsing capabilities

- ---> However, when we have code that is more complex, like specific variable types or attributes (ex. __uint()), we need to explicitly define them in a rule to ensure that Coccinelle knows exactly what to look for and how to handle it.

- This repo in particular (changeMap) demonstrates how a single transformation goal (which is to change a BPF map type) can be expressed in different ways (albeit small changes), where the differences are due to what we define in a rule and abstraction.

- ---> Therefore, there is no set way in making transformations. However, you must be able to understand how context-sensitive matching may affect your spatch application. For instance, these spatches will not work without defining attribute name SEC and 
declarer name __uint, as Coccinelle's built-in capabilities are unable to recognize and parse them. 


