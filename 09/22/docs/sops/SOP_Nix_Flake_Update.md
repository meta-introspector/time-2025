# SOP: Updating Nix Flakes

## 1. Purpose

This Standard Operating Procedure (SOP) outlines the process for updating Nix flakes and their dependencies. Regularly updating flakes ensures that your project benefits from the latest package versions, security fixes, and features, while maintaining reproducibility through `flake.lock`.

## 2. Scope

This SOP applies to all Nix flakes within the project, including the main project flake and any submodule flakes.

## 3. Prerequisites

*   Nix installed on your system (version 2.4 or later recommended).
*   `nix-command` and `flakes` experimental features enabled in your `nix.conf`.
*   A Git repository with a `flake.nix` and `flake.lock` file.

## 4. Procedure: Updating a Nix Flake

### 4.1. Updating the Main Project Flake

To update all inputs (dependencies) of the main project's `flake.nix` and record the new versions in `flake.lock`:

1.  **Navigate to the Project Root:**
    Ensure you are in the root directory of your `pick-up-nix` project.

2.  **Execute `nix flake update`:**
    ```bash
    nix flake update
    ```
    This command will fetch the latest versions of all inputs defined in your `flake.nix` and update the `flake.lock` file accordingly. It will also update any nested flakes (like submodules) if they are defined as inputs.

### 4.2. Updating a Specific Submodule Flake

To update a specific submodule's flake (e.g., `vendor/nix/nixtract`) without updating all other inputs of the main project:

1.  **Execute `nix flake update <FLAKE_PATH>`:**
    ```bash
    nix flake update /data/data/com.termux.nix/files/home/pick-up-nix2/vendor/nix/nixtract
    ```
    Replace `/data/data/com.termux.nix/files/home/pick-up-nix2/vendor/nix/nixtract` with the absolute path to the submodule's directory containing its `flake.nix`.

    This command will update only the inputs of the specified submodule's flake and its `flake.lock` file.

### 4.3. Reviewing Changes

After updating, it is good practice to review the changes in the `flake.lock` file using Git:

```bash
git diff flake.lock
```

This allows you to see which dependencies have been updated and to what versions.

## 5. Troubleshooting

*   **"Git tree is dirty" warning:** This warning indicates that there are uncommitted changes in the flake's directory. It's generally recommended to commit or stash your changes before updating to avoid conflicts.
*   **Build failures after update:** If your project fails to build after a flake update, it might be due to breaking changes in an updated dependency. You may need to:
    *   Pin the dependency to an older version in `flake.nix`.
    *   Adjust your code to be compatible with the new dependency version.
    *   Roll back the `flake.lock` to a previous state using Git.

## 6. Related Documentation

*   [CRQ-016: Submodule Nixification and Flake Refactoring](docs/crqs/CRQ_016_Submodule_Nixification.md)
*   [Memo: Use Shellcheck Always After Changes](docs/memos/Shellcheck_Always_After_Changes.md)
*   [CRQ-002: Nixtract Integration and Quality](docs/crqs/CRQ_002_Nixtract_Integration_and_Quality.md)
*   [SOP: Building the Nixtract Submodule](docs/sops/SOP_Build_Nixtract_Submodule.md)
*   [SOP: Nixtract Usage and Graph Generation](docs/sops/SOP_Nixtract_Usage.md)
