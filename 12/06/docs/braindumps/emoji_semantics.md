# Semantics of Emoji-Lisp and Low-Level Primitives

The Emoji-Lisp is a high-level symbolic representation. Its meaning (semantics) is derived from the Lisp primitives it represents. The challenge for the Mes-like bytecode is to faithfully capture these semantics in a minimal, low-level way.

- What are the minimal machine instructions needed to implement `eval`, `apply`, `cons`, `car`, `cdr`?
- How does garbage collection work in such a minimalist Lisp?
- The "hex loader" needs to be robust enough to handle the byte-level representation of these semantics.
- Is there a canonical, provably correct translation from Lisp-like AST to simple bytecode that preserves semantics? This is the core of verified compilation.
