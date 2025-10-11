# nix2make2nix: A Content-Addressable Build System

## Core Concept

The `nix2make2nix` system is envisioned as a content-addressable build system where every fundamental component—Make targets, Nix flakes, and the content they manage—is represented by abstract symbolic identifiers.

## Symbolic Representation: Emojis and Primes

These symbolic identifiers are primarily emoji strings or prime numbers, serving as unique, verifiable addresses for each element within the build graph.

## Nested Structure Example (Conceptual)

The system employs a nested, hierarchical structure for these symbolic representations, drawing inspiration from mathematical concepts. For instance, a component's address might be composed as follows:

*   **Level 1:** 42 pairs of emojis (conceptually representing a 2^46 binary structure).
*   **Level 2:** Nested with 20 triples of emojis (conceptually representing a 3^20 ternary structure).
*   **Level 3:** Further nested with 9 groups of five emojis (conceptually representing a 5^9 pentagonal structure).
*   ... and so on, down to a final object represented by 71 emojis.

This nested structure allows for a highly granular and verifiable addressing scheme, where each layer adds a dimension of content-addressability and symbolic meaning.

## Current Implementation Focus

The full complexity of this nested emoji/prime representation is not immediately required. The current focus is on establishing the foundational content-addressable build system, with the more intricate symbolic nesting to be implemented as complexity demands.