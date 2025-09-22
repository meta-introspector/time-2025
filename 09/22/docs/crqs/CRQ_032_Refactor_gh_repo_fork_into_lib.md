# CRQ-032: Refactor `gh repo fork` into `lib/` Function

## 1. Problem Statement

The project currently uses direct calls to `gh repo fork` in several shell scripts. This leads to:
*   Duplication of logic for common `gh repo fork` operations (e.g., specifying `--org`, `--clone=false`).
*   Lack of a centralized, reusable function for GitHub forking, making maintenance and future enhancements more difficult.
*   Inconsistent error handling and logging across different scripts.
*   Violation of the DRY principle, as identified in CRQ-018.

## 2. Proposed Solution

Refactor all direct usages of `gh repo fork` into a dedicated, reusable shell function within the `lib/` directory. This function will encapsulate the common parameters and provide a consistent interface for forking GitHub repositories.

The new function, tentatively named `lib_github_fork_repo`, will:
*   Accept parameters for the repository to fork, the target organization, and the desired fork name.
*   Handle common `gh repo fork` options (e.g., `--clone=false`).
*   Provide consistent error handling and logging.
*   Be located in `lib/lib_github_fork.sh`.

All existing scripts that use `gh repo fork` will be updated to call this new library function.

## 3. Scope

### In Scope
*   Creating this CRQ document.
*   Creating the `lib/lib_github_fork.sh` file.
*   Implementing the `lib_github_fork_repo` function.
*   Modifying the following scripts to use `lib_github_fork_repo`:
    *   `scripts/vendorize_flake_lock.sh`
    *   `scripts/vendorize_and_fork_submodule.sh`
    *   `scripts/automate_dependency_forking.sh` (if it's found to execute `gh repo fork` directly, otherwise ensure it uses the new lib function for its forking logic)
    *   `tag_submodules.sh`
    *   `lib/lib_github.sh` (removed duplicate `fork_github_repo` function)
    *   `lib/lib_git_submodule.sh`
    *   `source/github/meta-introspector/time/2024/04/10/forkall2.sh`
    *   `source/github/meta-introspector/time/2024/04/10/forkall.sh`
*   Creating `scripts/extract_and_vendorize_github_repos.sh` to utilize `lib_github_fork_repo`.
*   Creating `docs/sops/SOP_Extract_and_Vendorize_GitHub_Repos.md` to document the new script.
*   Updating `scripts/generate_refactoring_sed_scripts.sh` to generate `sed` commands that use the new `lib_github_fork_repo` function.
*   Ensuring no direct `gh repo fork` calls remain in any `.sh` script outside of `lib/lib_github_fork.sh`.
*   Updating relevant SOPs (e.g., `SOP_Automated_GitHub_Forking.md` if it exists, or creating one) to reflect the new standardized approach.

### Out of Scope
*   Changes to `flake.nix` files.
*   Refactoring other `gh` CLI commands (this CRQ focuses solely on `gh repo fork`).
*   Implementing new forking logic beyond what `gh repo fork` already provides.

## 4. Technical Details

*   **New File:** `lib/lib_github_fork.sh`
*   **New Function:** `lib_github_fork_repo <original_repo_url> <target_org> <fork_name>`
*   **Dependencies:** `gh` CLI must be installed and authenticated.
*   **Refactoring Strategy:**
    1.  Create `lib/lib_github_fork.sh` with the `lib_github_fork_repo` function.
    2.  For each identified script, replace the direct `gh repo fork` command with a call to `lib_github_fork_repo`.
    3.  Ensure proper parameter passing and error handling.

## 5. Testing Plan

1.  **Integration Test `lib_github_fork_repo`:** Execute `./tests/lib/test_lib_github_fork.sh` and verify its output. Follow the instructions in `docs/sops/SOP_Testing_lib_github_fork.md` for running the test and manual verification.
2.  **Integration Test Scripts:**
    *   Run `scripts/vendorize_flake_lock.sh` and verify that it correctly forks a repository using the new library function.
    *   Run `scripts/vendorize_and_fork_submodule.sh` and verify its functionality.
    *   Run `scripts/automate_dependency_forking.sh` in a scenario where it would perform a fork and verify it uses the new library function.
    *   Verify that `scripts/generate_refactoring_sed_scripts.sh` now generates `sed` commands that correctly reference `lib_github_fork_repo`.
3.  **Code Scan:** Perform a final search across all `.sh` files to confirm no direct `gh repo fork` calls remain outside of `lib/lib_github_fork.sh`.

## 6. Rollback Plan

*   Revert the changes made to `lib/lib_github_fork.sh`.
*   Revert the modifications made to the affected scripts.
*   Delete `CRQ_032_Refactor_gh_repo_fork_into_lib.md`.

## 7. Future Considerations

*   Expand `lib_github_fork_repo` to include more advanced `gh repo fork` options as needed.
*   Consider creating a more generic `lib_github_cli.sh` for other `gh` commands.

## 8. Approval

[ ] Approved by: [Name]
[ ] Date: [Date]
