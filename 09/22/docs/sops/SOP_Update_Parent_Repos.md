# SOP: Updating Parent Repositories

## 1. Purpose

This Standard Operating Procedure (SOP) describes the use of the `update_parent_repos.sh` script to synchronize changes across multiple related Git repositories. This is crucial for maintaining consistency in development branches and applying common updates (e.g., related to Nix flake integration or submodule consistency) across a project's repository hierarchy.

## 2. Scope

This SOP applies to developers and maintainers who need to propagate changes, commit, and push updates to a predefined set of parent Git repositories within the project.

## 3. Prerequisites

-   A working Bash environment.
-   `lib_exec.sh` and `lib_git_submodule.sh` libraries sourced.
-   Proper Git configuration, including remote origins and push permissions for the target repositories.
-   The script should be executed from a Git repository that is part of the update process, or from a location where the specified repository paths are accessible.

## 4. Procedure

The `scripts/update_parent_repos.sh` script automates the process of updating specified Git repositories.

### 4.1. Script Location

The script is located at: `/data/data/com.termux.nix/files/home/pick-up-nix2/source/github/meta-introspector/streamofrandom/2025/09/22/scripts/update_parent_repos.sh`

### 4.2. Usage

The script supports optional arguments:

-   `--dry-run`: If provided, the script will simulate the Git operations without actually making any changes or pushing to remotes.
-   `--tags`: If provided, the script will also create and push Git tags (functionality depends on `process_single_repo` in `lib_git_submodule.sh`).

**Example Execution:**

```bash
# To perform a dry run
/data/data/com.termux.nix/files/home/pick-up-nix2/source/github/meta-introspector/streamofrandom/2025/09/22/scripts/update_parent_repos.sh --dry-run

# To perform a real update and push tags
/data/data/com.termux.nix/files/home/pick-up-nix2/source/github/meta-introspector/streamofrandom/2025/09/22/scripts/update_parent_repos.sh --tags
```

### 4.3. Script Functionality

The script performs the following steps:

1.  **Argument Parsing**: It parses `--dry-run` and `--tags` arguments and sets corresponding internal flags.
2.  **Source Libraries**: It sources `lib_exec.sh` and `lib_git_submodule.sh` to access utility functions.
3.  **Defines Update Parameters**: 
    -   `BRANCH_NAME`: Hardcoded to `feature/808017424794512875886459904961710757005754368000000000`.
    -   `COMMIT_MESSAGE`: Hardcoded to `CRQ-016: Update for flake.nix integration and submodule consistency`.
4.  **Processes Repositories**: It iterates through a predefined list of repositories (currently the current repository, `nix2`, and `streamofrandom`) and calls the `process_single_repo` function (from `lib_git_submodule.sh`) for each.
    -   `process_single_repo` handles checking out the specified branch, adding all changes, committing with the defined message, and pushing to the remote. If `--tags` is enabled, it also creates and pushes tags.

## 5. Customization

-   To change the target repositories, modify the `REPOS` associative array within the script.
-   To change the branch name or commit message, modify the `BRANCH_NAME` and `COMMIT_MESSAGE` variables within the script.

## 6. Verification

-   After execution, review the script's output for any errors or warnings.
-   If not in dry-run mode, check the remote repositories to confirm that the new commits and (if `--tags` was used) tags have been pushed to the specified branch.

## 7. Related Files

-   `/data/data/com.termux.nix/files/home/pick-up-nix2/source/github/meta-introspector/streamofrandom/2025/09/22/lib/lib_exec.sh`: Provides the `execute_cmd` function.
-   `/data/data/com.termux.nix/files/home/pick-up-nix2/source/github/meta-introspector/streamofrandom/2025/09/22/lib/lib_git_submodule.sh`: Provides Git utility functions like `process_single_repo`.
-   The Git repositories defined in the `REPOS` array.
