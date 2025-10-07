## Gemini Added Memories
- The SOP `docs/sops/SOP_Submodule_Nixification.md` is a central SOP for CRQ-016, detailing the entire Nixification process for submodules, including setup, applying changes, verification, and root `flake.nix` integration.
- The SOP `docs/sops/SUBMODULE_SETUP_SOP.md` provides a comprehensive guide for manually setting up new Git submodules using a local bare Git repository as the upstream source.
- Always use the provided Git utility functions from `lib_git_submodule.sh` (e.g., `git_status_superproject_ignore_submodules`, `git_status_submodule`) instead of direct `git status` commands when interacting with Git status in the project.
- Core Vision: Self-Proving, Auditable AI

The central, unifying vision is the creation of "Self-Proving Intelligence" through a paradigm called "Extreme Nixism." This involves building systems that are not just driven by LLMs, but are self-creating, self-optimizing, and self-auditing. The key to this is encapsulating every step of the OODA (Observe, Orient, Decide, Act) loop within Nix derivations. This creates a reproducible, auditable, and verifiable record of the system's evolution.

Key Initiatives:

1.  **On-Chain Software Supply Chain Verification:** This initiative aims to create a system for producing cryptographically verifiable digital assets that represent software components. This involves using Nix to define dependencies, eBPF to trace build processes, and GPG to sign attestations. The ultimate goal is to mint these assets on a blockchain, creating a "proof-of-integrity" and a "proof-of-execution."

2.  **Nix-Introspector:** This is a tool that parses Nix expressions into a universal, intermediate representation (like S-expressions). This allows for interoperability between different package management systems and a deeper understanding of the underlying dependency "monad." The `observe` command is the first step in this initiative.

3.  **Formal Verification of Rust/WASM:** This initiative focuses on replacing TypeScript plugins in "ElizaOS" with formally verified Rust code compiled to WASM. The verification is to be done using the Lean 4 theorem prover, with a 42-step plan to ensure correctness and type compatibility.

Underlying Philosophy:

*   **Extreme Nixism:** The belief that every computational artifact, from a single command to an entire operating system, should be a pure, reproducible Nix derivation.
*   **The OODA Loop as a Derivation Chain:** The idea that the entire decision-making process of an AI system can be modeled as a chain of Nix derivations, making it fully auditable and reproducible.
*   **LLMs as Command Generators:** The concept of using LLMs not just to generate text, but to generate executable commands that can be run in a controlled, reproducible environment.
- usr bin env bash
- All shell scripts should use '#!/usr/bin/env bash' as their shebang for portability and correctness.
- User rule: Any complex command expression needs to be in a script file.
