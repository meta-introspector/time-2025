# SOP: Integrating Nix-based Pre-commit Hooks

This Standard Operating Procedure (SOP) outlines the steps to integrate the project's Nix-based pre-commit hook system into your local Git repository. This system ensures code quality, consistency, and adherence to project standards by automatically running linters and formatters before each commit.

## Prerequisites

*   **Nix Package Manager:** Ensure Nix is installed and configured on your system.
*   **Nix Flakes Enabled:** Verify that Nix flakes are enabled in your Nix configuration (`extra-experimental-features = nix-command flakes` in `~/.config/nix/nix.conf` or `/etc/nix/nix.conf`).
*   **Git:** Ensure Git is installed.

## Procedure

Follow these steps to set up the pre-commit hooks:

1.  **Navigate to the Project Root:**
    Open your terminal and navigate to the root directory of your project:
    ```bash
    cd /data/data/com.termux.nix/files/home/pick-up-nix2/source/github/meta-introspector/streamofrandom/2025/09/27/
    ```

2.  **Run the Setup Script:**
    Execute the provided setup script. This script will enter the Nix development environment and install the pre-commit Git hooks.
    ```bash
    ./setup_precommit_hooks.sh
    ```
    You should see output similar to:
    ```
    Navigating to project directory: ...
    Entering Nix development shell and installing pre-commit hooks...
    pre-commit installed at .../hooks/pre-commit
    Pre-commit hooks setup complete. They will now run automatically on git commit.
    You can test them by trying to commit a file that violates a hook rule.
    ```

3.  **Verify Installation (Optional):**
    You can verify that the hooks are installed by checking the `.git/hooks` directory:
    ```bash
    ls -l .git/hooks/pre-commit
    ```
    You should see that `pre-commit` is a symbolic link created by the `pre-commit` tool.

## Usage

Once installed, the pre-commit hooks will automatically run whenever you attempt a `git commit`.

*   **Successful Hooks:** If all hooks pass, your commit will proceed as usual.
*   **Failed Hooks:** If any hook fails (e.g., due to formatting issues, linting errors, or non-conventional commit messages), the commit will be aborted, and you will see output indicating which hook failed and why. You must fix the reported issues before you can successfully commit.

## Available Hooks

The following hooks are currently configured:

*   `nixpkgs-fmt`: Automatically formats `.nix` files.
*   `statix`: Performs static analysis on `.nix` files.
*   `shellcheck`: Lints shell scripts (`.sh` files).
*   `commitlint`: Enforces conventional commit message format.

## Troubleshooting

*   **`pre-commit` not found:** Ensure you have run `./setup_precommit_hooks.sh`. If you are outside the `nix develop` environment, `pre-commit` might not be in your PATH.
*   **Hook failures:** Read the error messages carefully. They will guide you on how to fix the issues.
*   **Updating hooks:** To update the pre-commit hooks (e.g., after changes to `.pre-commit-config.yaml` or tool versions in `flake.nix`), simply re-run `./setup_precommit_hooks.sh`.
