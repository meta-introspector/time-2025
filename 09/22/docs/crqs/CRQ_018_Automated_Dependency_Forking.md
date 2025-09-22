# CRQ-018: Automated Forking of Nix Flake Dependencies

- **ID**: CRQ-018
- **Status**: Draft
- **Author**: Gemini Agent
- **Date**: 2025-09-21
- **Related Documents**: CRQ-016, SOP_Submodule_Nixification.md

## 1. Problem Statement

Our project relies on numerous external Nix flakes defined as inputs in our `flake.nix` files. These dependencies are typically referenced directly from their original GitHub repositories (e.g., `github:owner/repo`). This creates a significant supply chain risk:
- If an upstream repository is deleted or made private, our builds will fail.
- If an upstream repository is compromised or a malicious commit is force-pushed, our builds could become insecure or unreliable.

We lack a systematic process for ensuring that all external GitHub dependencies are forked into our own controlled GitHub organization (`meta-introspector`) to mitigate these risks.

## 2. Proposed Solution

Create a shell script, `scripts/ensure_dependency_forks.sh`, that automates the process of identifying and forking missing external Nix flake dependencies.

The script will perform the following steps:
1.  Fetch a list of all current repositories within the `meta-introspector` GitHub organization and store it locally.
2.  Scan all `flake.nix` files within the project (as indexed in `index/file_nix.txt`) to identify all `github:` dependencies.
3.  For each dependency, check if a fork already exists in the `meta-introspector` organization.
4.  If a fork does not exist, the script will use the `gh` CLI to fork the repository into the `meta-introspector` organization.

This provides a repeatable and automated way to secure our software supply chain.

## 3. Scope

### In Scope

-   Creating a new CRQ document for this task.
-   Developing the `scripts/ensure_dependency_forks.sh` automation script.
-   Generating an index of repositories in the `meta-introspector` organization.
-   Identifying external `github:` dependencies from all `flake.nix` files.
-   Forking any missing dependencies into the `meta-introspector` organization.
-   Creating a tutorial in `docs/tutorials/` to document the new script and its role in our workflow.

### Out of Scope

-   Modifying the `flake.nix` files to point to the newly created forks. This will be handled in a subsequent task.
-   Handling non-GitHub dependencies (e.g., GitLab, source tarballs).
-   Managing updates for the forked repositories.

## 4. Technical Details

-   **Tools**: The script will be written in `bash` and will leverage the following tools:
    -   `gh` (GitHub CLI): For interacting with the GitHub API to list organization repositories and to fork them.
    -   `jq`: For parsing the JSON output from the `gh` CLI.
    -   `grep`, `sed`, `awk`: For text processing and extracting dependency information from `flake.nix` files.
-   **Input**: A list of `flake.nix` file paths, sourced from `index/file_nix.txt`.
-   **Output**: Forks of missing dependencies created in the `meta-introspector` GitHub organization.

## 5. Testing Plan

1.  Create a temporary `flake.nix` file with a known, public dependency that is not currently forked in `meta-introspector`.
2.  Run the script.
3.  Verify that the script correctly identifies the missing dependency.
4.  Confirm that the script executes `gh repo fork` with the correct parameters.
5.  Check the `meta-introspector` organization on GitHub to ensure the new fork has been created.
6.  Run the script again and verify that it does not attempt to re-fork the same repository.

## 6. Rollback Plan

The script is largely non-destructive. The primary action is the creation of new forks on GitHub. In the event of an issue:
-   The generated `index/github_metaintrospector_repos.json` file can be deleted.
-   Any incorrectly forked repositories can be manually deleted from the `meta-introspector` GitHub organization.
