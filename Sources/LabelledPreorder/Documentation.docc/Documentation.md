# ``LabelledPreorder``


## Overview

Implicit coercions in proof assistants and programming languages are difficult to implement. The main problem is *coherence*, which is the property that given two types `A` and `B`, the set of registered coercions from `A` to `B` is subsingleton (up to some appropriate notion of definitional equivalence).

The precise mathematical structure governing implicit coercions, is then, a *labelled preorder*: edges can be composed, and these compositions are coherent with the labelling up to definitional equivalence.

In the PhD thesis “Refinement and extension of mathematical structures in proof assistants based on dependent type theory”, Kazuhiko Sakaguchi designed an appropriate data structure and algorithm for maintaining the coherence property of a labelled preorder. The idea is to start with a labelled graph that contains its own reflexive-transitive closure; when inserting a new edge, you must insert *all* the induced edges under reflexive-transitive closure, and we must check that the induced diamonds all commute. Sakaguchi minimises the set of diamonds that we must check by noticing that the commmutation of certain distinguished “irreducible” diamonds implies the commutation of the rest.

Sakaguchi’s algorithm is [implemented as part of the Rocq proof assistant](https://github.com/rocq-prover/rocq/pull/13909). Our own version of the data structure is slightly simplified, as we consider only the case of completely discrete vertices (e.g. names of theories) and use definitional equality checks only on the coercion paths themselves.

Our implementation is parameterised in a notion of path admitting an potentially asynchronous definitional equality check. This should be applicable to implementing certain forms of implicit coercion, type classes, and locales in a variety of tools.
