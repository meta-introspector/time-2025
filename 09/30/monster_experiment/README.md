# Monster Experiment: Wikidata Extraction and NAR Compilation

This directory houses the "Monster Experiment," focused on extracting data from Wikidata and compiling it into Nix Archive (NAR) files. The goal is to leverage Nix flakes for a reproducible and potentially "impure" data processing pipeline.

## Purpose

The primary objective of this experiment is to:
1.  **Extract Wikidata:** Utilize a Rust-based knowledge extractor to fetch and parse web content, potentially from Wikidata or related sources.
2.  **Compile into NARs:** Transform the extracted knowledge into Nix Archive (NAR) files for efficient storage and distribution within the Nix ecosystem.
3.  **Impure Nix Flake:** Develop an impure Nix flake that allows for necessary network access during the data extraction phase, while still maintaining a degree of reproducibility for the overall process.

## Current Status

As of September 30, 2025, the following components are in place:

*   **`rust_knowledge_extractor/`:** Contains a Rust project capable of fetching, parsing, and optimizing web content, outputting structured JSON. This is a core component for the Wikidata extraction.
*   **`context/first.md`:** Documents the initial setup context of the Gemini CLI.
*   **`context/yesterday.md`:** Summarizes the Git log of changes from September 27th, providing historical context for the project's evolution.
*   **Nix Flake Integration Attempt:** An attempt has been made to integrate the `rust_knowledge_extractor` into a Nix flake structure.

## Challenges Encountered

During the Nix flake integration, a persistent issue has been encountered where Nix struggles to correctly resolve the source path for the `rust_knowledge_extractor` flake when it's nested within a larger Git repository that also contains a `flake.nix` in a parent directory (`streamofrandom/2025/09/flake.nix`). This leads to errors like `error: getting status of '/nix/store/...-source/09/30': No such file or directory`.

## Next Steps (Plan)

The immediate plan is to resolve the Nix flake build issue for `rust_knowledge_extractor`. This will involve:
1.  **Fixing Parent Flake Interaction:** Correctly integrate the `rust_knowledge_extractor` sub-flake into the parent `flake.nix` (`streamofrandom/2025/09/flake.nix`) by ensuring all inputs are properly defined and passed.
2.  **Successful Build:** Achieve a successful Nix build of the `rust_knowledge_extractor` package.
3.  **NAR Compilation Strategy:** Once the extraction is working, define and implement a strategy for compiling the extracted knowledge (JSON output) into NAR files. This might involve additional Nix derivations or scripts.
4.  **Impurity Management:** Ensure the "impure" aspect of the flake (network access for `reqwest`) is handled appropriately, likely within a `devShell` or a specific build phase that explicitly allows network access.
