# SOP: Check and Rectify Git Submodules

## 1. Purpose

This Standard Operating Procedure (SOP) outlines the process for verifying and rectifying the origin and branch of Git submodules within the project. It ensures that all submodules point to `meta-introspector` forks and are on the `feature/CRQ-016-nixify-workflow` branch, promoting consistency and adherence to project standards.

## 2. Scope

This SOP applies to all Git submodules within the project that are intended to be managed under the `meta-introspector` organization and participate in the Nixification workflow (CRQ-016).

## 3. Prerequisites

*   A local clone of the main project repository.
*   `git` installed and configured.
*   `gh` (GitHub CLI) installed and authenticated with permissions to fork and push to `meta-introspector` repositories.
*   The `scripts/generate_submodule_status.sh` script must have been run recently to create `index/submodules_status.txt`.
*   The `scripts/vendorize_and_fork_submodule.sh` script must exist and be executable.
*   The `scripts/check_and_rectify_submodules.sh` script must exist and be executable.

## 4. Procedure

To check and rectify submodules, use the `scripts/check_and_rectify_submodules.sh` script:

1.  **Ensure Submodule Status is Up-to-Date (if necessary):**
    If `index/submodules_status.txt` is not recent, run:
    ```bash
    ./scripts/generate_submodule_status.sh
    ```

2.  **Execute the Rectification Script:**
    Run the `check_and_rectify_submodules.sh` script from the project root:
    ```bash
    ./scripts/check_and_rectify_submodules.sh
    ```

### 4.3. Script Quality Assurance

Before executing any of the scripts mentioned in this SOP, always run `shellcheck` on them to ensure code quality and catch potential errors. Refer to [Memo: Use Shellcheck Always After Changes](../../docs/memos/Shellcheck_Always_After_Changes.md) for details.

```bash
shellcheck scripts/generate_submodule_status.sh
shellcheck scripts/vendorize_and_fork_submodule.sh
shellcheck scripts/check_and_rectify_submodules.sh
```

## 5. How it Works

The `check_and_rectify_submodules.sh` script performs the following actions:

1.  Reads the `index/submodules_status.txt` file to get a list of all submodules and their current status.
2.  Iterates through each submodule.
3.  For each submodule, it determines its current remote URL and active branch.
4.  It checks if the submodule's origin is a `meta-introspector` repository and if its active branch is `feature/CRQ-016-nixify-workflow`.
5.  If a submodule does not meet these criteria, the script attempts to rectify it by calling `scripts/vendorize_and_fork_submodule.sh`. This script will:
    *   Ensure the submodule's remote points to the `meta-introspector` fork.
    *   Create and/or check out the `feature/CRQ-016-nixify-workflow` branch.
    *   Push the branch to the `meta-introspector` fork.
6.  Logs its actions and findings to stdout.

## 6. Troubleshooting

*   **`index/submodules_status.txt` not found**: Run `scripts/generate_submodule_status.sh`.
*   **`gh` authentication errors**: Ensure `gh` is authenticated and has the necessary permissions.
*   **Script errors**: Check the output for specific error messages. Ensure all prerequisite scripts are executable and pass `shellcheck`.

## 7. Related Documents

*   [CRQ-016: Submodule Nixification and Flake Refactoring](docs/crqs/CRQ_016_Submodule_Nixification.md)
*   [SOP: Vendorizing and Forking a Git Submodule](docs/sops/SOP_Vendorize_And_Fork_Submodule.md)
*   [SOP: Submodule Nixification and Flake Refactoring](docs/sops/SOP_Submodule_Nixification.md)
*   [Memo: Use Shellcheck Always After Changes](docs/memos/Shellcheck_Always_After_Changes.md)
*   `scripts/generate_submodule_status.sh`
*   `scripts/vendorize_and_fork_submodule.sh`
