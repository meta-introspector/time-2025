# SOP: Check Git Submodule and Flake Status

## 1. Purpose

This Standard Operating Procedure (SOP) describes how to check the local Git status and the Nix flake configuration (specifically the `nixpkgs` input URL) of a specified Git submodule. This helps in debugging inconsistencies and ensuring submodules are in the expected state.

## 2. Prerequisites

*   The `check_submodule_flake_status.sh` script must be present in the `scripts/` directory and be executable.
*   The submodule must be initialized and updated.

## 3. Usage

To use the script, execute it from the project root directory, providing the path to the submodule as an argument:

```bash
./scripts/check_submodule_flake_status.sh <SUBMODULE_PATH>
```

**Example:**
```bash
./scripts/check_submodule_flake_status.sh vendor/nix/nixtract
```

## 4. Expected Output

The script will output the following information:

*   **Git Status (local):** The output of `git status` within the specified submodule's directory. This will show:
    *   Current branch and its relation to the remote.
    *   Any modified, staged, or untracked files.
    *   Whether the working tree is clean.
*   **Flake Version (nixpkgs input URL from flake.nix):** The URL of the `nixpkgs` input as defined in the submodule's `flake.nix` file. This indicates which version of Nixpkgs the submodule is configured to use.
*   **Report on Differences:** A conceptual guide on how to interpret the output to identify inconsistencies.

## 5. Interpretation of Results

*   **"nothing to commit, working tree clean"**: The submodule's local state matches its last committed state.
*   **"Changes not staged for commit" / "Untracked files"**: Indicates local modifications or new files that are not yet part of the submodule's Git history. These may need to be staged and committed.
*   **"Your branch is ahead of 'origin/...' by X commits"**: The submodule has local commits that have not been pushed to its remote.
*   **Differences in Nixpkgs URL**: If the `nixpkgs` URL differs from the expected version, it might indicate that the submodule's Nix environment is not aligned with the project's standards.

## 6. Troubleshooting

*   **Script not found/executable:** Ensure the path to `check_submodule_flake_status.sh` is correct and that it has execute permissions (`chmod +x scripts/check_submodule_flake_status.sh`).
*   **Script errors**: If the `check_submodule_flake_status.sh` script itself is failing, ensure it passes `shellcheck`. Refer to [Memo: Use Shellcheck Always After Changes](docs/memos/Shellcheck_Always_After_Changes.md) for details.

## 7. Related Documents

*   `scripts/generate_submodule_status.sh`: Generates a status report for all submodules, which can be used to get an overview before drilling down with this script.
*   [Memo: Use Shellcheck Always After Changes](docs/memos/Shellcheck_Always_After_Changes.md)

## 8. CRQ Association

This SOP is part of the ongoing efforts related to CRQ-016 (Submodule Nixification and Flake Refactoring), as it provides a tool for maintaining consistency and debugging issues within the Nix-enabled submodules.
