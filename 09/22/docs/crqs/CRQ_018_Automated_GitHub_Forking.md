# CRQ-018: Automated GitHub Forking for Nix Flake Dependencies

## 1. Problem Statement

The project relies on external Nix flake dependencies, often referenced directly from their original GitHub repositories. This poses supply chain risks (upstream deletion, compromise) and makes local development less robust. We need a systematic way to ensure all external GitHub dependencies are forked into our controlled `meta-introspector` GitHub organization.

## 2. Proposed Solution

Develop a shell script, `scripts/automate_dependency_forking.sh`, to identify and fork missing external Nix flake dependencies.

The script will:
1.  List all repositories in the `meta-introspector` GitHub organization and store them in `index/github_metaintrospector_repos.json`.
2.  Read all `flake.nix` files (from `index/file_nix.txt`) to identify `github:` sources.
3.  For each `github:` dependency, check if a corresponding fork exists in `index/github_metaintrospector_repos.json`.
4.  If a fork does not exist, check for name ambiguity (e.g., if a repo with the same name but different owner exists).
5.  If no ambiguity and no existing fork, use `gh repo fork` to create a fork in the `meta-introspector` organization.
6.  The script will also support a `--report` flag to perform a dry-run, listing dependencies and indicating whether they would be forked without actually performing the fork operation.

## 3. Scope

### In Scope
*   Creating this CRQ document.
*   Developing `scripts/automate_dependency_forking.sh`.
*   Generating `index/github_metaintrospector_repos.json`.
*   Identifying `github:` dependencies from `flake.nix` files.
*   Implementing logic to check for existing forks and name ambiguity.
*   Using `gh repo fork` to create new forks.
*   Documenting the process in `docs/tutorials/Automated_Dependency_Forking_Tutorial.md`.

### Out of Scope
*   Modifying `flake.nix` files to point to the newly created forks (this will be a separate CRQ).
*   Handling non-GitHub dependencies.
*   Managing updates for forked repositories.

## 4. Technical Details

*   **Tools**: `bash`, `gh` (GitHub CLI), `jq`, `grep`, `sed`, `awk`.
*   **Input**: `index/file_nix.txt` (list of `flake.nix` paths).
*   **Output**: `index/github_metaintrospector_repos.json` (list of `meta-introspector` repos), new forks on GitHub.
*   **Reuse**: Leverage existing code patterns from `scripts/` for Git operations and file parsing. This CRQ will also serve as an opportunity to refactor existing shell scripts (`*.sh` and `scripts/*.sh`) into reusable functions and libraries, adhering to the DRY principle.

## 5. Testing Plan

1.  Run `scripts/automate_dependency_forking.sh --report` and verify that it correctly identifies dependencies and indicates which ones would be forked without performing any actual forking.
2.  Manually create a `flake.nix` with a public GitHub dependency not yet forked.
3.  Run `scripts/automate_dependency_forking.sh`.
4.  Verify `index/github_metaintrospector_repos.json` is updated.
5.  Confirm the new fork appears in the `meta-introspector` GitHub organization.
6.  Run the script again to ensure idempotency (no re-forking).
7.  Test with a dependency that has a name conflict to ensure ambiguity handling.

## 6. Rollback Plan

*   Delete `index/github_metaintrospector_repos.json`.
*   Manually delete any incorrectly created forks from the `meta-introspector` GitHub organization.

## 7. Future Considerations

*   Automate updating `flake.nix` files to point to forked repositories.
*   Implement a mechanism for periodically syncing forked repositories with their upstream counterparts.

## 8. Approval

[ ] Approved by: [Name]
[ ] Date: [Date]
