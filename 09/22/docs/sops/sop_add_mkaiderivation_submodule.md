# SOP: Adding mkAIDerivation Git Submodule

## Purpose:
This Standard Operating Procedure (SOP) outlines the steps for adding the `mkAIDerivation` project as a Git submodule to the main repository.

## Procedure:

1.  **Navigate to the project root:**
    ```bash
    cd /data/data/com.termux.nix/files/home/pick-up-nix2/
    ```

2.  **Add the submodule:**
    Use the `git submodule add` command with the repository URL and the desired path.
    ```bash
    git submodule add https://github.com/meta-introspector/mkAIDerivation.git vendor/mkAIDerivation
    ```
    *   If the submodule already exists, Git will report that the path is already in the index. In this case, proceed to step 3.

3.  **Initialize and Update Submodules:**
    After adding, or if the submodule already existed, ensure all submodules are initialized and updated.
    ```bash
    git submodule update --init --recursive
    ```

4.  **Verify the Submodule Status:**
    Check the status of the submodules to ensure `mkAIDerivation` is correctly added and initialized.
    ```bash
    git submodule status
    ```

5.  **Commit Changes:**
    Commit the changes to `.gitmodules` and the new submodule directory.
    ```bash
    git add .gitmodules vendor/mkAIDerivation
    git commit -m "feat: Add mkAIDerivation as a Git submodule"
    ```

## Related Documents:
*   [CRQ-016: Submodule Nixification and Flake Refactoring](docs/crqs/CRQ_016_Submodule_Nixification.md)
*   [Memo: Use Shellcheck Always After Changes](docs/memos/Shellcheck_Always_After_Changes.md)
*   `docs/sops/sop_update_submodules.md`
*   `tools/add_mkaiderivation_submodule.sh`

**Note on `tools/add_mkaiderivation_submodule.sh`**: If you use or modify this script, always run `shellcheck` on it to ensure code quality and catch potential errors. Refer to [Memo: Use Shellcheck Always After Changes](docs/memos/Shellcheck_Always_After_Changes.md) for details.
