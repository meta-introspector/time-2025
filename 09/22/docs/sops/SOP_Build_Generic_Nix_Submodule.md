# SOP: Building a Generic Nix Submodule

## 1. Purpose

This Standard Operating Procedure (SOP) outlines the steps to build a generic Git submodule independently using Nix. This ensures that any Nix-enabled submodule can be built and verified in isolation, contributing to its standalone operation and quality control.

## 2. Scope

This SOP applies to developers and contributors who need to build or test any Nix-enabled submodule within the project.

## 3. Prerequisites

*   Nix installed on your system (version 2.4 or later recommended).
*   `nix-command` and `flakes` experimental features enabled in your `nix.conf`.
*   The target submodule must be initialized and updated (e.g., `git submodule update --init --recursive`).

## 4. Procedure: Building a Nix Submodule

### 4.1. Using the `build_generic_nix_submodule.sh` Script

The project provides a convenience script, `scripts/build_generic_nix_submodule.sh`, to automate the process of building a Nix submodule.

1.  **Navigate to the Project Root (Recommended):**
    It is recommended to execute the script from the root directory of your `pick-up-nix` project.

2.  **Execute the Script:**
    Run the `build_generic_nix_submodule.sh` script, providing the relative path to the target Nix submodule as an argument. You can also use the `--offline` option to prevent network access during the build.

    ```bash
    ./scripts/build_generic_nix_submodule.sh [--offline] vendor/nix/my-submodule
    ```

    *   `vendor/nix/my-submodule`: This is an example relative path to a Nix submodule from the project root.

    The script will first perform a dry run to show the build plan and then attempt the actual build. If successful, it will indicate that the Nix submodule was built successfully and provide the path to the build result in the Nix store.

## 5. Troubleshooting

*   **"Usage: ..." error:** Ensure you provide the path to the Nix submodule as an argument to the script.
*   **"Error: Dry run failed..." or "Error: Failed to build Nix submodule."**: Check the output for specific Nix build errors. This could be due to missing dependencies, syntax errors in the submodule's `flake.nix`, or network issues. If using `--offline`, ensure all dependencies are available locally.
*   **Nix experimental features not enabled:** Ensure `nix-command` and `flakes` are enabled in your `nix.conf`.
*   **Script errors**: If the `build_generic_nix_submodule.sh` script itself is failing, ensure it passes `shellcheck`. Refer to [Memo: Use Shellcheck Always After Changes](docs/memos/Shellcheck_Always_After_Changes.md) for details.

## 6. Related Documentation

*   [CRQ-016: Submodule Nixification and Flake Refactoring](docs/crqs/CRQ_016_Submodule_Nixification.md)
*   [CRQ-002: Nixtract Integration and Quality](docs/crqs/CRQ_002_Nixtract_Integration_and_Quality.md)
*   [Memo: Use Shellcheck Always After Changes](docs/memos/Shellcheck_Always_After_Changes.md)
*   [SOP: Nixtract Usage and Graph Generation](docs/sops/SOP_Nixtract_Usage.md)
*   [SOP: Nix Graph Analysis](docs/sops/SOP_Nix_Graph_Analysis.md)
*   [Tutorial: Building Nix Submodules](docs/tutorials/Tutorial_Build_Generic_Nix_Submodule.md)
