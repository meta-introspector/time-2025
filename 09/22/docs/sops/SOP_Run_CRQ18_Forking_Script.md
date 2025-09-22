# SOP: Running the CRQ-018 Automated Dependency Forking Script

## 1. Purpose

This Standard Operating Procedure (SOP) outlines the steps for executing the `automate_dependency_forking.sh` script within its dedicated Nix development environment. This ensures that the script runs with all necessary dependencies (`jq`, `gh`) available, promoting reproducibility and consistency.

## 2. Scope

This SOP applies to anyone needing to run the automated GitHub forking process as defined by CRQ-018.

## 3. Prerequisites

*   Nix installed on your system with `nix-command` and `flakes` experimental features enabled.
*   The `scripts/automate_dependency_forking.sh` script must exist and be executable.
*   The `flakes/crq-018/flake.nix` must exist and be committed to Git.
*   The `scripts/run_crq18_forking_script.sh` must exist and be executable.

## 4. Procedure

To run the `automate_dependency_forking.sh` script, use the wrapper script `run_crq18_forking_script.sh`:

1.  **Navigate to the Project Root:**
    Ensure you are in the root directory of your `pick-up-nix` project.

2.  **Execute the Wrapper Script:**
    Run `scripts/run_crq18_forking_script.sh` and pass any arguments you would normally pass to `automate_dependency_forking.sh`.

    *   **For a dry run (report mode):**
        ```bash
        ./scripts/run_crq18_forking_script.sh --report
        ```

    *   **To perform the actual forking:**
        ```bash
        ./scripts/run_crq18_forking_script.sh
        ```

### 4.3. Script Quality Assurance

Before executing `scripts/run_crq18_forking_script.sh` or `scripts/automate_dependency_forking.sh`, always run `shellcheck` on them to ensure code quality and catch potential errors. Refer to [Memo: Use Shellcheck Always After Changes](../../docs/memos/Shellcheck_Always_After_Changes.md) for details.

```bash
shellcheck scripts/run_crq18_forking_script.sh
shellcheck scripts/automate_dependency_forking.sh
```

## 5. How it Works

The `run_crq18_forking_script.sh` script performs the following actions:

1.  It changes the current directory to `flakes/crq-018/`.
2.  It then uses `nix develop --command bash -c "..."` to enter the development shell defined by `flakes/crq-018/flake.nix`.
3.  Within this development shell, it executes the `automate_dependency_forking.sh` script, passing along any arguments provided to the wrapper script.

This ensures that `jq` and `gh` (as defined in `flakes/crq-018/flake.nix`) are available in the environment where `automate_dependency_forking.sh` runs.

## 6. Troubleshooting

*   **Nix errors**: Ensure your Nix installation is correct and experimental features are enabled. Check the output for specific Nix error messages.
*   **Script errors**: If `automate_dependency_forking.sh` fails, check its output for details. Ensure `gh` is authenticated and `jq` is correctly installed via the flake.
*   **`flake.nix` not found**: Ensure `flakes/crq-018/flake.nix` exists and is committed to Git.
*   **`run_crq18_forking_script.sh` not executable**: Run `chmod +x scripts/run_crq18_forking_script.sh`.

## 7. Related Documents

*   [CRQ-018: Automated GitHub Forking for Nix Flake Dependencies](docs/crqs/CRQ_018_Automated_GitHub_Forking.md)
*   [CRQ-016: Submodule Nixification and Flake Refactoring](docs/crqs/CRQ_016_Submodule_Nixification.md)
*   [Memo: Use Shellcheck Always After Changes](docs/memos/Shellcheck_Always_After_Changes.md)
*   `scripts/automate_dependency_forking.sh`
*   `flakes/crq-018/flake.nix`
