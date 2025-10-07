# Task: Debugging and Enhancing Pre-commit Hooks

## Current Status

The pre-commit hook setup has been implemented with `flake.nix`, `.pre-commit-config.yaml`, `commit.sh`, `setup_precommit_hooks.sh`, `crq_commit_msg_check.sh`, `crq_document_check.sh`, and `script_sop_check.sh`.

However, recent commit attempts have failed with the following persistent issues:

1.  **`commitlint` not found:** The `pre-commit` framework reports `Executable commitlint not found` when running the `commitlint` hook. This indicates that `commitlint` is not in the PATH when `pre-commit` executes the hook, despite `commit.sh` wrapping `git commit` in a `nix develop` environment.
2.  **`CRQ Commit Message Check` failure:** The `crq_commit_msg_check.sh` hook incorrectly fails, reporting that the commit message does not start with a CRQ number or conventional type, even when it does.
3.  **`CRQ Document Existence Check` failure:** The `crq_document_check.sh` hook incorrectly reports that the CRQ document does not exist, even when it does. This suggests an issue with `git rev-parse --show-toplevel` or path resolution within the hook's execution context.

## Root Cause Analysis (Hypothesis)

The primary issue seems to be related to how `pre-commit` executes `language: system` hooks and how it interacts with the Nix development environment's PATH and working directory. It appears that the PATH from `nix develop` is not fully inherited or respected by `pre-commit` for `language: system` hooks, leading to executables not being found. Additionally, path resolution within the hooks might be problematic.

## Plan to Resolve

1.  **Re-evaluate `commit.sh` and `pre-commit` interaction:**
    *   The `nix develop --command bash -c 'git commit "$@"' -- "$@"` approach in `commit.sh` is intended to provide the Nix environment. If `pre-commit` hooks are not inheriting this, we need a more robust way to ensure the PATH.
    *   A potential solution is to explicitly set the PATH within the `entry` of each `language: system` hook in `.pre-commit-config.yaml` to include the Nix store paths of the required tools. This is brittle.
    *   A better approach might be to ensure `pre-commit` itself is run within the Nix environment, and then `pre-commit` manages the PATH for its hooks.

2.  **Debug `crq_commit_msg_check.sh` and `crq_document_check.sh`:**
    *   Add `set -x` to these scripts to trace their execution and see what values `$1` (commit message file) and `PROJECT_ROOT` are resolving to.
    *   Verify the `grep -E` pattern and ensure it's correctly matching the commit message.

3.  **Consider `pre-commit`'s `language: nix` or `language: system` with explicit `PATH`:**
    *   If `language: system` continues to be problematic, explore if `pre-commit` has a `language: nix` option or if we need to manually construct the PATH for each hook.

## Next Linter: No Inline Scripts (and tweak `shellcheck`)

The user also requested to add the "next linter" and specifically mentioned "no inline scripts" and "tweak shellcheck to flag them."

This implies:

1.  **Identify a linter for inline scripts:** This is a bit ambiguous. It could mean:
    *   A linter that checks for scripts embedded within other file types (e.g., bash in Markdown).
    *   A linter that flags shell scripts that are *not* standalone files (e.g., snippets).
    *   A linter that flags scripts that are not properly documented.

2.  **Tweak `shellcheck`:** `shellcheck` can be configured to flag various issues. I need to investigate `shellcheck` options to see if it can flag "inline scripts" or scripts that lack proper shebangs/documentation.

## Immediate Action

Given the current debugging state, the most important next step is to resolve the `commitlint` and CRQ check failures. The user's instruction to reboot into Nix suggests a fresh start, which is good.
