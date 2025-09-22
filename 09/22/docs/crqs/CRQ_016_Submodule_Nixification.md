# CRQ-016: Submodule Nixification and Flake Refactoring

## 1. Overview

This Change Request (CRQ) details the process of standardizing and integrating Nix flakes across the project's submodules, particularly those under `vendor/nix/`. The primary goal is to establish a robust and repeatable workflow for managing Nix environments within submodules, addressing inconsistencies and enabling a more reliable development experience. This CRQ also covers the refactoring of the root `flake.nix` to aggregate these submodule flakes efficiently.

## 2. Problem Statement

Prior to this CRQ, the project faced challenges related to:
*   Inconsistent or missing `flake.nix` files in submodules, leading to difficulties in setting up reproducible development environments.
*   Lack of a standardized process for updating and managing Nix configurations within submodules.
*   Errors in `nix develop` due to broken or incompatible `flake.nix` files in submodules.
*   The root `flake.nix` directly referencing individual submodule repositories on GitHub, which is less flexible and harder to manage.

## 3. Proposed Solution

The solution involves a multi-faceted approach:
*   **Standardized `flake.nix` Template**: Creation of a `flake.template` to ensure all submodule `flake.nix` files adhere to a consistent structure and include essential development tools.
*   **Automated Nixification Scripts**: Development of a suite of shell scripts (`branch_and_push_all.sh`, `commit_and_push_flakes.sh`, `commit_crq_submodule.sh`, `fix_submodule.sh`, `inject_submodule_env.sh`, `nixify.sh`, `nixify_vendor_nix.sh`, `commit_workflow.sh`) to automate the creation, update, commitment, and pushing of `flake.nix` files in submodules.
*   **Automated Submodule Rectification**: Development of `scripts/check_and_rectify_submodules.sh` to ensure submodules point to `meta-introspector` forks and are on the `feature/CRQ-016-nixify-workflow` branch.
*   **Branching Strategy**: Implementation of a dedicated feature branch (`feature/CRQ-016-nixify`) within each submodule to isolate Nixification changes.
*   **Root `flake.nix` Refactoring**: Updating the main project's `flake.nix` to aggregate submodule flakes via a local `vendor/nix/flake.nix`, improving modularity and local development efficiency.
*   **Documentation**: Creation of comprehensive documentation (CRQ, SOP, script documentation) to guide future maintenance and development.

## 4. Scope

### In-Scope:
*   Creation and standardization of `flake.nix` files in `vendor/nix/*` submodules.
*   Development and documentation of automation scripts for submodule Nixification.
*   Refactoring of the root `flake.nix` to consume aggregated submodule flakes.
*   Creation of a dedicated feature branch (`feature/CRQ-016-nixify`) in each affected submodule.
*   Updating `.gitignore` to properly ignore generated log files.

### Out-of-Scope:
*   Nixification of submodules outside of `vendor/nix/`.
*   Detailed testing of the functionality provided by each submodule's `flake.nix` (beyond basic `nix develop` functionality).
*   Changes to the core logic or features of the submodules themselves.

## 5. Technical Details

### Files Created/Modified:
*   `docs/crqs/CRQ_016_Flake_Refactor_and_Nixify.md` (initial version, updated)
*   `flake.nix` (root)
*   `index/pre-commit.txt` (new)
*   `scripts/flake.template` (new)
*   `scripts/branch_and_push_all.sh` (new)
*   `scripts/commit_and_push_flakes.sh` (new, modified)
*   `scripts/commit_crq_submodule.sh` (modified)
*   `scripts/fix_submodule.sh` (new)
*   `scripts/inject_submodule_env.sh` (modified)
*   `scripts/nixify.sh` (new)
*   `scripts/nixify_vendor_nix.sh` (new, modified)
*   `scripts/commit_workflow.sh` (new)
*   `scripts/check_and_rectify_submodules.sh` (new)
*   `vendor/nix/flake.nix` (new)
*   `.gitignore` (modified)
*   `docs/scripts/*.md` (new documentation for each script)

### Key Changes:
*   **Root `flake.nix`**: Now references `vendor/nix/flake.nix` as a local input, which in turn aggregates individual submodule flakes.
*   **Submodule `flake.nix`**: Generated from `flake.template`, providing a consistent `devShell` with `bash`, `git`, `asciinema`, `pre-commit`, and `shellcheck`.
*   **Automation Scripts**: Provide a robust mechanism for applying these changes across multiple submodules, handling branching, committing, and pushing.
*   **Submodule Rectification Script**: A new script to automatically check and rectify submodule origins and branches.

## 6. Testing

Testing involved:
*   **Dry-run execution**: Using `nixify.sh` without `--apply` to preview changes.
*   **Manual verification**: Inspecting generated `flake.nix` files and `.pre-commit-config.yaml` files.
*   **Script execution**: Running `nixify_vendor_nix.sh --apply` and `commit_and_push_flakes.sh` to ensure automated changes and Git operations complete successfully.
*   **Git status checks**: Verifying that submodules are on the correct branches and changes are committed.

## 7. Rollback Plan

In case of issues, the following rollback steps can be taken:
1.  **Revert main repository commits**: Use `git revert <commit-hash>` for the commits related to this CRQ in the main repository.
2.  **Revert submodule branches**: In each affected submodule, switch to the previous branch (e.g., `master`) and delete the `feature/CRQ-016-nixify` branch.
3.  **Restore backed-up files**: If `flake.nix.bak` files exist in submodules, restore them.

## 8. Future Considerations

*   Extend Nixification to other submodules outside `vendor/nix/`.
*   Integrate more sophisticated testing for submodule `devShell` functionality.
*   Explore further automation for managing submodule remotes and forks.

## 9. Approval

[ ] Approved by: [Name]
[ ] Date: [Date]
