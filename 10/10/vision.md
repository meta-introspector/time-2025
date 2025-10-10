# Vision: LLM-Driven Nix Workflow with Architectural Closure

This document outlines the core workflow and architectural principles for our LLM-driven software engineering tasks, leveraging Nix flakes for reproducibility and P2P systems for artifact sharing.

## The Workflow: Nix as Input, NAR as Output, NARs as New Flake Inputs

Our system operates on an iterative cycle where pure inputs are transformed by an impure LLM-driven process, yielding impure derived outputs in the form of Nix Archive (NAR) files. These NAR files are then published and can serve as new inputs for subsequent stages, creating a powerful feedback loop.

### 1. Pure Inputs to Impure System

We begin with **pure inputs**, which are well-defined and reproducible Nix flake references. These include:

*   **`flakeSource`**: A reference to the main repository (e.g., `github:meta-introspector/time-2025?ref=feature/lattice-30030-homedir&dir=...`) that provides the context for the task.
*   **`inputFlakes`**: Other Nix flakes defining the inputs to the LLM task, potentially with constraints.
*   **`processFlakes`**: Nix flakes defining the processes or transformations to be applied, possibly including invariants.
*   **`outputFlakes`**: Nix flakes defining the expected structure and targets for the outputs.

These pure inputs are fed into an **impure system**, specifically the `llmGeneratedFlake` derivation within the `plan` phase of our tasks.

### 2. LLM Interaction and Impure Output Generation

Within the `llmGeneratedFlake` derivation, an LLM (accessed via a generic `llmInterface` flake) is prompted with the composition parameters derived from our pure inputs. The LLM's role is to:

*   **Generate a New Flake Definition:** The LLM's response is expected to be a *new Nix flake definition* (a `flake.nix` content). This is considered an **impure derived output** because the LLM's generation process is inherently non-reproducible.
*   **Build to NAR:** This LLM-generated `flake.nix` is then built into a Nix Archive (NAR) file.

### 3. NAR as Output and P2P Publication

The NAR file of this LLM-generated flake serves as the primary output of the `llmGeneratedFlake` derivation. This NAR file is then conceptually **published** to a P2P storage system (e.g., Git, IPFS, ZK-rollups). This step makes the impure output available for subsequent stages and sharing across the system.

### 4. NARs as New Flake Inputs

Crucially, these published NAR files (which are valid Nix store paths) can then be referenced as **new inputs** to other Nix flakes or subsequent stages of the workflow. This establishes a continuous, self-referential loop where the output of one LLM-driven step becomes a verifiable input for the next.

## Key Architectural Principles

This workflow is built upon several key architectural principles:

*   **Architectural Closure:** The system is designed to be self-referential and iterative. The output of the LLM-driven planning phase (a NAR-wrapped flake) can feed back into the system as a new input, enabling continuous refinement and evolution.
*   **Composition over Embedding:** We prioritize composing flakes by referencing them as inputs rather than embedding Nix expressions as strings. This promotes modularity, reusability, and maintainability.
*   **Impurity Encapsulation:** The inherently non-reproducible LLM interaction is carefully encapsulated within a specific impure derivation (`llmGeneratedFlake`). This allows the rest of the system to remain as pure and reproducible as possible, isolating the non-deterministic aspects.
*   **P2P for Artifact Sharing:** Leveraging P2P storage for NAR files provides a robust, decentralized, and auditable mechanism to share and track these LLM-generated artifacts.

This vision aims to create a highly flexible, auditable, and self-improving system for complex software engineering tasks.