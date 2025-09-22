# SOP: Vendorizing and Forking a Git Submodule

## 1. Purpose

This Standard Operating Procedure (SOP) outlines the process of vendorizing a Git repository as a submodule within the project, ensuring it is forked under the `meta-introspector` organization and set to a specific branch. This process is crucial for maintaining control over external dependencies, ensuring reproducibility, and aligning with project-specific branching strategies.

## 2. Scope

This SOP applies to all developers and contributors who need to integrate new external Git repositories as submodules or manage existing ones within the project, especially when those repositories need to be forked and maintained under the `meta-introspector` organization.

## 3. Prerequisites

*   Git installed and configured.
*   `gh` (GitHub CLI) installed and authenticated with access to the `meta-introspector` organization.
*   The main project repository must be cloned and accessible.

## 4. Procedure: Vendorizing and Forking a Git Submodule

### 4.1. Using the `vendorize_and_fork_submodule.sh` Script

The project provides a convenience script, `scripts/vendorize_and_fork_submodule.sh`, to automate this process.

1.  **Navigate to the Project Root (Recommended):**
    Ensure you are in the root directory of your `pick-up-nix` project.

2.  **Execute the Script:**
    Run the `vendorize_and_fork_submodule.sh` script, providing the original GitHub repository URL and the desired local submodule path as arguments.

    ```bash
    ./scripts/vendorize_and_fork_submodule.sh github:numtide/flake-utils vendor/nix/flake-utils
    ```

    *   `github:numtide/flake-utils`: The original GitHub repository URL (can also be `https://github.com/numtide/flake-utils.git`).
    *   `vendor/nix/flake-utils`: The desired local path where the submodule will be added.

    The script will perform the following actions:
    *   Check if the submodule already exists. If not, it will add it.
    *   Ensure a remote named `meta-introspector` exists in the submodule, pointing to the `meta-introspector` fork of the repository. If the fork doesn't exist, it will attempt to create it using `gh cli`.
    *   Fetch the `feature/CRQ-016-nixify-workflow` branch from the `meta-introspector` remote.
    *   Check out the `feature/CRQ-016-nixify-workflow` branch in the submodule.
    *   Push the `feature/CRQ-016-nixify-workflow` branch to the `meta-introspector` remote.

## 5. Troubleshooting

*   **"Usage: ..." error:** Ensure you provide both the original repository URL and the submodule path as arguments.
*   **`gh` CLI errors:** Ensure `gh` is installed and you are authenticated with sufficient permissions to fork repositories under the `meta-introspector` organization.
*   **Git errors:** Check the output for specific Git errors (e.g., network issues, authentication problems).
*   **Branch not found:** If the `feature/CRQ-016-nixify-workflow` branch does not exist in the `meta-introspector` fork, the script will fail when trying to fetch/checkout. You may need to manually create this branch in the forked repository.
*   **Script errors**: If the `vendorize_and_fork_submodule.sh` script itself is failing, ensure it passes `shellcheck`. Refer to [Memo: Use Shellcheck Always After Changes](docs/memos/Shellcheck_Always_After_Changes.md) for details.

## 6. Related Documentation

*   [CRQ-002: Nixtract Integration and Quality](docs/crqs/CRQ_002_Nixtract_Integration_and_Quality.md)
*   [CRQ-016: Submodule Nixification and Flake Refactoring](docs/crqs/CRQ_016_Submodule_Nixification.md)
*   [SOP: Building a Generic Nix Submodule](docs/sops/SOP_Build_Generic_Nix_Submodule.md)
*   [Tutorial: Vendorizing and Forking Git Submodules](docs/tutorials/Tutorial_Vendorize_And_Fork_Submodule.md)
