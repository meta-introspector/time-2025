# CRQ-002: Nixtract Integration and Quality

## 1. Title

Nixtract Integration, Quality Control, and Standalone Operation

## 2. Problem Statement

The `nixtract` tool is crucial for understanding the Nix dependency graphs within the project. However, its current usage is ad-hoc, and it is not fully integrated into the project's quality system. Specifically:

*   There is no formal process for ensuring the quality and reliability of `nixtract`'s output.
*   The `nixtract` submodule (`vendor/nix/nixtract`) lacks project-specific quality control mechanisms (e.g., linting, testing, CI integration).
*   The ability to run `nixtract` in a standalone, reproducible manner, especially within the Gemini CLI environment, needs to be formalized and integrated.
*   The `boot.sh` and Gemini CLI functions are not integrated into the `nixtract` submodule's development or testing workflow.

## 3. Proposed Solution

This Change Request proposes to enhance the integration and quality of the `nixtract` submodule by:

1.  **Formalizing `nixtract` Usage**: Documenting its usage through SOPs (`SOP_Nixtract_Usage.md`, `SOP_Nix_Graph_Analysis.md`).
2.  **Implementing Quality Control**: Injecting project-specific quality control procedures (e.g., linting, testing, build checks) into the `vendor/nix/nixtract` submodule.
3.  **Ensuring Standalone Operation**: Verifying and enabling the `nixtract` submodule to operate and be tested independently.
4.  **Integrating Gemini CLI Functions**: Adding `boot.sh` and Gemini CLI functions to the `nixtract` submodule's workflow to facilitate automated testing and interaction.

## 4. Scope

*   Creation of new SOPs and CRQs related to `nixtract`.
*   Modification of files within `vendor/nix/nixtract` to include quality checks and integration points.
*   Development of scripts or configurations to enable standalone operation and Gemini CLI interaction within the `nixtract` submodule.
*   Updating relevant project documentation.

## 5. Technical Details

*   **Quality System Injection**: This will involve adding configuration files (e.g., `.github/workflows/`, `flake.nix` modifications) and scripts (e.g., `test.sh`, `lint.sh`) to the `vendor/nix/nixtract` submodule.
*   **Standalone Operation**: Ensure that `nix develop` or `nix build` within `vendor/nix/nixtract` works as expected, providing a functional development environment and build artifact.
*   **Gemini CLI Integration**: This may involve creating a wrapper script within `vendor/nix/nixtract` that can call the main project's `boot.sh` and then execute Gemini CLI commands, passing context as needed.

## 6. Testing

*   Verify that `nixtract` can be built and run successfully from within its submodule directory.
*   Ensure that new quality checks (linting, testing) pass within the `nixtract` submodule.
*   Test the integration of `boot.sh` and Gemini CLI functions by executing a sample task within the `nixtract` submodule's environment.

## 7. Rollback Plan

In case of issues, changes can be rolled back by reverting the commits associated with this CRQ in both the main repository and the `vendor/nix/nixtract` submodule.

## 8. Associated Commits

*   [Commit Hash] - [Commit Message]

## 9. Related Documentation

*   [SOP: Nixtract Usage and Graph Generation](docs/sops/SOP_Nixtract_Usage.md)
*   [SOP: Nix Graph Analysis](docs/sops/SOP_Nix_Graph_Analysis.md)
*   [SOP: Updating Nix Flakes](docs/sops/SOP_Nix_Flake_Update.md)
*   [SOP: Building a Generic Nix Submodule](docs/sops/SOP_Build_Generic_Nix_Submodule.md)
