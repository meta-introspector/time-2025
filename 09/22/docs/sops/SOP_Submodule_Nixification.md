# SOP: Submodule Nixification and Flake Refactoring

## 1. Purpose

This Standard Operating Procedure (SOP) outlines the steps for standardizing and integrating Nix flakes across the project's submodules, particularly those under `vendor/nix/`. It ensures a consistent, reproducible, and automated approach to managing Nix environments within submodules, thereby improving development efficiency and reducing inconsistencies.

## 2. Scope

This SOP applies to all submodules located under the `vendor/nix/` directory that require a standardized Nix development environment.

## 3. Prerequisites

*   A working Git environment with access to the project repository.
*   `git` command-line tool installed.
*   `nix` package manager installed and configured.
*   `gh` (GitHub CLI) installed and authenticated.
*   Familiarity with basic Git and Nix flake concepts.
*   The `scripts/` directory contains the necessary automation scripts (`branch_and_push_all.sh`, `commit_and_push_flakes.sh`, `commit_crq_submodule.sh`, `fix_submodule.sh`, `inject_submodule_env.sh`, `nixify.sh`, `nixify_vendor_nix.sh`, `commit_workflow.sh`, `vendorize_flake_urls.sh`, `apply_vendorized_urls.sh`).
*   The `scripts/flake.template` file exists and contains the desired base `flake.nix` structure.

## 4. Procedure

### 4.1. Initial Setup (if not already done)

1.  **Ensure `flake.template` is up-to-date**: Verify that `scripts/flake.template` contains the desired standard `flake.nix` content for submodules.
2.  **Verify Automation Scripts**: Ensure all necessary scripts in `scripts/` are present and executable.

### 4.2. Applying Nixification to Submodules

1.  **Navigate to Project Root**: Open your terminal and navigate to the root directory of the main project.
    ```bash
    cd /path/to/your/project
    ```
2.  **Run Nixification Script (Dry Run)**: Execute the `nixify_vendor_nix.sh` script in dry-run mode to see what changes would be made without actually applying them.
    ```bash
    ./scripts/nixify_vendor_nix.sh
    ```
    Review the output to understand the proposed changes.
3.  **Run Nixification Script (Apply Changes)**: If the dry-run output is satisfactory, execute the script with the `--apply` flag to create or update the `flake.nix` files in the submodules.
    ```bash
    ./scripts/nixify_vendor_nix.sh --apply
    ```
    This will create `flake.nix` files (if missing) or update existing ones, backing up old versions to `flake.nix.bak`.
4.  **Commit and Push Submodule Changes**: Execute the `commit_and_push_flakes.sh` script to commit the changes within each submodule, create a dedicated feature branch (`feature/CRQ-016-nixify`), and push these changes to their respective remote repositories.
    ```bash
    ./scripts/commit_and_push_flakes.sh
    ```
    This script will:
        *   Ensure the `feature/CRQ-016-nixify-workflow` branch is checked out (or created) in each submodule.
    *   Commit the `flake.nix` changes (and any other staged changes) in each submodule with a CRQ-prefixed commit message.
    *   Push the new branch to the submodule's remote. (Note: Tagging of submodules is currently skipped as per user request.)

### 4.3. Verifying Changes

1.  **Check Git Status**: After running the scripts, verify the Git status of the main repository and individual submodules to ensure all changes are committed and branches are correctly pushed.
    ```bash
    git status
    git submodule foreach 'git status'
    ```
2.  **Run Shellcheck on Modified Scripts**: If any shell scripts were modified or created as part of the Nixification process, always run `shellcheck` to ensure code quality and catch potential errors. Refer to [Memo: Use Shellcheck Always After Changes](docs/memos/Shellcheck_Always_After_Changes.md) for details.
3.  **Inspect `flake.nix` files**: Manually inspect a few `flake.nix` files in the `vendor/nix/*` submodules to confirm they match the `flake.template` and contain the expected content.
4.  **Test `nix develop`**: Navigate into a submodule and attempt to enter its development shell to ensure it functions as expected.
    ```bash
    cd vendor/nix/nixtract
    nix develop
    # Verify tools like bash, git, shellcheck are available
    exit
    ```

### 4.4. Root `flake.nix` Integration

1.  **Update Root `flake.nix`**: Ensure the main project's `flake.nix` is updated to reference the aggregated `vendor/nix/flake.nix` as an input, rather than individual submodule repositories. This step should have been completed as part of the CRQ implementation.
2.  **Commit Root `flake.nix` Changes**: Commit any changes made to the root `flake.nix` in the main repository.

## 5. Troubleshooting

*   **"No meta-introspector repositories found"**: If `nixify_vendor_nix.sh` or `commit_and_push_flakes.sh` fails with this error, ensure the scripts are updated to correctly discover submodules by finding `flake.nix` files in `vendor/nix` subdirectories (as per CRQ-016 modifications).
*   **Git Push Rejected**: If a `git push` operation is rejected, it likely means the remote repository has changes not present locally. Ensure the correct branch is checked out in the submodule and consider using `git pull --rebase` if appropriate (though the scripts aim to avoid this by creating new branches).
*   **`flake.nix.bak` files**: These are backups of previous `flake.nix` files. Review them if unexpected changes occurred.

## 6. Related Documents

*   CRQ-016: Submodule Nixification and Flake Refactoring
*   CRQ-018: Automated GitHub Forking for Nix Flake Dependencies
*   CRQ-019: Secure Credential Handling in Nix Scripts
*   `scripts/branch_and_push_all.sh` documentation
*   `scripts/commit_and_push_flakes.sh` documentation
*   `scripts/commit_crq_submodule.sh` documentation
*   `scripts/fix_submodule.sh` documentation
*   `scripts/inject_submodule_env.sh` documentation
*   `scripts/nixify.sh` documentation
*   `scripts/nixify_vendor_nix.sh` documentation
*   `scripts/commit_workflow.sh` documentation
*   `scripts/vendorize_flake_urls.sh` documentation
*   `scripts/apply_vendorized_urls.sh` documentation
*   [Memo: Use Shellcheck Always After Changes](docs/memos/Shellcheck_Always_After_Changes.md)
