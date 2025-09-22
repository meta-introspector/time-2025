# SOP: Updating Git Submodules

## Purpose:
This Standard Operating Procedure (SOP) outlines the steps for updating all Git submodules within the main repository.

## Procedure:

1.  **Navigate to the project root:**
    ```bash
    cd /data/data/com.termux.nix/files/home/pick-up-nix2/
    ```

2.  **Update all submodules:**
    Use the `git submodule update` command with the `--init` and `--recursive` flags to ensure all submodules are initialized and updated, including nested submodules.
    ```bash
    git submodule update --init --recursive
    ```

3.  **Verify Submodule Status:**
    Check the status of all submodules to ensure they are up-to-date.
    ```bash
    git submodule status
    ```

## Related Documents:
*   [CRQ-016: Submodule Nixification and Flake Refactoring](docs/crqs/CRQ_016_Submodule_Nixification.md)
*   [SOP: Submodule Nixification and Flake Refactoring](docs/sops/SOP_Submodule_Nixification.md)
*   `docs/sops/sop_add_mkaiderivation_submodule.md`
*   `tools/update_all_submodules.sh`
*   [Memo: Use Shellcheck Always After Changes](docs/memos/Shellcheck_Always_After_Changes.md)

**Note on `tools/update_all_submodules.sh`**: If you use or modify this script, always run `shellcheck` on it to ensure code quality and catch potential errors. Refer to [Memo: Use Shellcheck Always After Changes](docs/memos/Shellcheck_Always_After_Changes.md) for details.
