# SOP: Generic Nix Flake Testing Procedure

## 1. Purpose

This Standard Operating Procedure (SOP) outlines a generic method for testing any Nix flake within the project. It provides a standardized way to verify that a flake's development environment (`devShell`) can be entered and its default package can be built, logging all output for review.

## 2. Scope

This SOP applies to all Nix flakes within the project, including main project flakes and submodule flakes.

## 3. Prerequisites

*   Nix installed on your system with `nix-command` and `flakes` experimental features enabled.
*   The target flake's directory must exist and contain a valid `flake.nix` file.
*   The `scripts/test_flake.sh` script must exist and be executable.

## 4. Procedure: Testing a Nix Flake

To test a Nix flake, use the `scripts/test_flake.sh` wrapper script:

1.  **Navigate to the Project Root:**
    Ensure you are in the root directory of your `pick-up-nix` project.

2.  **Execute the Test Script:**
    Run `scripts/test_flake.sh` and provide the relative path to the flake's directory as an argument.

    ```bash
    ./scripts/test_flake.sh <RELATIVE_PATH_TO_FLAKE_DIR>
    ```

    *   **Example:** To test the CRQ-018 flake:
        ```bash
        ./scripts/test_flake.sh flakes/crq-018
        ```

### 4.3. Script Quality Assurance

Before executing `scripts/test_flake.sh`, always run `shellcheck` on it to ensure code quality and catch potential errors. Refer to [Memo: Use Shellcheck Always After Changes](../../docs/memos/Shellcheck_Always_After_Changes.md) for details.

```bash
shellcheck scripts/test_flake.sh
```

## 5. Expected Output and Logging

The script will log all its actions and the output from `nix develop` and `nix build` commands to a dedicated log file. The log file will be named `flake_test_<FLAKE_DIR_BASENAME>_YYYYMMDD_HHMMSS.log` and will be created in the directory from which the script is executed.

*   **Successful Test:** The log file will indicate successful entry into the `nix develop` shell and successful building of the default package.
*   **Failed Test:** The log file will contain error messages from `nix develop` or `nix build`, which can be used for troubleshooting.

## 6. Troubleshooting

*   **"Usage: ..." error:** Ensure you provide the relative path to the flake directory as an argument.
*   **"Error: Flake path ... does not exist."**: Verify the provided path is correct and points to an existing directory containing a `flake.nix`.
*   **Nix errors**: Review the generated log file for specific Nix error messages. This could indicate issues with the `flake.nix` itself, missing inputs, or build failures.
*   **`test_flake.sh` not executable**: Run `chmod +x scripts/test_flake.sh`.

## 7. Related Documents

*   [CRQ-016: Submodule Nixification and Flake Refactoring](docs/crqs/CRQ_016_Submodule_Nixification.md)
*   [Memo: Use Shellcheck Always After Changes](docs/memos/Shellcheck_Always_After_Changes.md)
*   `scripts/test_flake.sh`
*   `flakes/crq-018/flake.nix` (example flake)
