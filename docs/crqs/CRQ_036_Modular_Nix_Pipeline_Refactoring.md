# CRQ-036: Modular Nix Pipeline Refactoring for 2-Gram Indexer

## 1. Problem Statement

The current implementation of the Nix 2-gram indexer, particularly within the `nix_2gram_indexer.nix` module and its dependencies (e.g., `nix_2gram_indexer_stepX.nix`), exhibits a critical flaw related to Nix's lazy evaluation model. Modules are sourced from a `builtins.fetchTarball` (or now `builtins.fetchGit`), and attempt to access the output (`.out` path) of unbuilt derivations during the evaluation phase. This leads to persistent `error: cannot operate on output 'out' of the unbuilt derivation` errors.

Specifically, derivations like `nix-file-index` are defined, but their outputs are consumed by subsequent steps (e.g., via `builtins.readFile` or `cat` within `pkgs.runCommand`) before Nix has had a chance to build them to the store. This issue is exacerbated by the current modular structure where intermediate derivations are passed directly between imported modules, rather than their built store paths.

## 2. Proposed Solution: Modular Nix Pipeline Architecture

To resolve the "unbuilt derivation" error and align with best practices for modularity, explicit dependencies, and efficient caching in Nix, we propose refactoring the 2-gram indexer into a modular Nix pipeline. Each logical step of the indexing process will be treated as a distinct, self-contained Nix package or flake.

### 2.1. Architectural Principles

*   **Separate Nix Packages/Flakes per Step:** Each `nix_2gram_indexer_stepX.nix` (and potentially `nix_code_indexer.nix` and `n_gram_generator.nix` if they represent distinct, reusable components) will be converted into its own Nix package or flake.
*   **Explicit Inputs and Outputs (Store Paths):**
    *   Each step will define its inputs explicitly, expecting *store paths* (e.g., `/nix/store/...`) from previous steps, rather than unbuilt derivations.
    *   Each step will produce a single, well-defined output to the Nix store.
*   **Git References for Dependencies:** Dependencies between steps (i.e., one step consuming the output of another) will be managed by referencing the Git repository (and specific commit/branch) of the producing step. This ensures reproducibility and allows for granular versioning.
*   **Strict Evaluation and Building:** The pipeline will enforce that each step is fully built to the Nix store before its output is consumed by the next step.
*   **Makefile Orchestration:** A central `Makefile` will be responsible for:
    *   Sequentially building each step's Nix package/flake.
    *   Passing the store path output of a completed step as an input to the next step.
    *   Managing Git operations (e.g., committing and pushing changes to individual step repositories/branches).

### 2.2. Benefits

*   **Resolution of "Unbuilt Derivation" Errors:** By explicitly building each step and passing store paths, the lazy evaluation issues will be eliminated.
*   **Improved Modularity and Reusability:** Each step becomes an independent, reusable component that can be developed, tested, and versioned in isolation.
*   **Enhanced Caching:** Nix's caching mechanisms will be fully leveraged, as each step's output is a distinct store path, preventing redundant builds.
*   **Clearer Dependency Graph:** The explicit input/output contracts between steps will make the overall pipeline's dependency graph transparent and easier to understand.
*   **Adherence to Nix Best Practices:** This architecture aligns with idiomatic Nix development for complex, multi-stage build processes.
*   **Facilitates Git-based Workflow:** Directly supports the user's requirement to reference previous steps via Git and manage changes through Git.

## 3. Implementation Strategy (High-Level)

1.  **Identify Step Boundaries:** Clearly define the input and output for each `nix_2gram_indexer_stepX.nix` (and potentially `nix_code_indexer.nix`, `n_gram_generator.nix`).
2.  **Convert to Flakes/Packages:** For each step, create a new Nix flake or package definition that takes its inputs and produces its output.
3.  **Update `inspect_indexer_output.nix`:** Modify this file to orchestrate the building of these new flakes/packages sequentially.
4.  **Refactor `Makefile`:** Implement targets to build each step and pass outputs as inputs to subsequent steps.
5.  **Version Control:** Ensure each step's definition (if it becomes a separate repository) is properly versioned in Git.

## 4. Open Questions / Next Steps

*   Confirmation of the exact Git repository structure for each step (e.g., are they all in `time-2025`, or will they be separate repositories?).
*   Detailed design of the input/output contracts for each step.
*   Decision on whether to use `builtins.fetchGit` directly in each step or to manage dependencies via a top-level `flake.nix`'s `inputs`.
