# Plan for the Monster Experiment

## Phase 1: Resolve `rust_knowledge_extractor` Nix Flake Build Issue

1.  **Identify and Address Parent Flake Interference:** The primary obstacle is the interaction between the `rust_knowledge_extractor`'s `flake.nix` and the parent `flake.nix` in `streamofrandom/2025/09/`. 
    *   **Current Approach:** The parent `flake.nix` has been modified to include `rustKnowledgeExtractor` as a local path input and its output in the `packages` attribute. The `outputs` function signature also needs to be updated to accept `rustKnowledgeExtractor`.
    *   **Next Action:** Correct the `outputs` function signature in the parent `flake.nix` to include `rustKnowledgeExtractor` as an argument.
2.  **Achieve Successful Build:** Once the parent flake correctly references the sub-flake, attempt to build the `rust_knowledge_extractor` package through the parent flake.

## Phase 2: Implement NAR Compilation Strategy

1.  **Define NAR Structure:** Determine the desired structure and content of the NAR files. How will the extracted JSON data be packaged into NARs?
2.  **Nix Derivation for NAR Creation:** Create a Nix derivation that takes the JSON output from `rust_knowledge_extractor` and transforms it into NAR files. This might involve:
    *   A custom script (e.g., Python or shell script) to process the JSON and create the NAR structure.
    *   Using existing Nix functions for file manipulation and packaging.

## Phase 3: Manage Impurity

1.  **Network Access for `rust_knowledge_extractor`:** Ensure that the `rust_knowledge_extractor` binary, when executed, has the necessary network access to fetch web content. This will likely be handled within the `devShell` or by running the binary in an environment that permits network access.
2.  **Document Impurity:** Clearly document where and why impurity is introduced in the flake, aligning with the user's request for an "impure flake."

## Phase 4: Orchestration and Integration

1.  **Workflow Definition:** Define the end-to-end workflow: how `rust_knowledge_extractor` is run, how its output is captured, and how it feeds into the NAR compilation process.
2.  **Scripting:** Create shell scripts or Nix functions to orchestrate the entire process, from data extraction to NAR generation.
