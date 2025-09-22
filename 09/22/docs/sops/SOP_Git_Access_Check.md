# SOP: Git Access Policy Check

## 1. Purpose

This Standard Operating Procedure (SOP) outlines the steps to verify adherence to the project's Git Access Policy. The policy mandates that all Git operations in shell scripts must utilize the centralized `scripts/lib_git_submodule.sh` library, prohibiting direct Git command invocations.

## 2. Scope

This SOP applies to all shell scripts (`.sh` files) within the project and is intended for use by developers, CI/CD systems, and quality assurance personnel.

## 3. Prerequisites

*   A local clone of the project repository.
*   The `rules/git_access/check.sh` script must be present and executable.

## 4. Procedure: Running the Git Access Policy Check

### 4.1. Executing the `check.sh` Script

1.  **Navigate to the Project Root (Recommended):**
    Ensure you are in the root directory of your `pick-up-nix` project.

2.  **Run the Check Script:**
    Execute the `check.sh` script located in `rules/git_access/`:

    ```bash
    ./rules/git_access/check.sh
    ```

    *   **Expected Output:**
        The script will scan all shell scripts (excluding `scripts/lib_git_submodule.sh`) for direct Git command invocations. If violations are found, it will report the file path and line number where the direct Git command was detected.

        Example of a violation report:
        ```
        Checking for direct Git command usage in shell scripts...
        Found direct Git command in: scripts/my_old_script.sh
        5:    git add .
        10:   git commit -m "Initial commit"

        Git access policy check complete.
        ```
        If no violations are found, the output will be:
        ```
        Checking for direct Git command usage in shell scripts...
        Git access policy check complete.
        ```

## 5. Remediation

If the `check.sh` script reports violations, you must refactor the identified shell scripts to use the corresponding functions from `scripts/lib_git_submodule.sh`. For example, replace `git add .` with a call to a function that encapsulates `git add`. If a required function does not exist in the library, it should be added to `scripts/lib_git_submodule.sh`. After refactoring, always run `shellcheck` on the modified script to ensure code quality. Refer to [Memo: Use Shellcheck Always After Changes](docs/memos/Shellcheck_Always_After_Changes.md) for details.

## 6. Troubleshooting

*   **Script not found/executable:** Ensure the path to `check.sh` is correct and that it has execute permissions (`chmod +x rules/git_access/check.sh`).
*   **False positives:** If a legitimate use of `git` is flagged (e.g., in a comment or a string that is not an executable command), you may need to refine the `GIT_COMMANDS` regex in `check.sh` or add specific exclusions.

## 7. Related Documentation

*   [Git Access Policy](docs/standards/Git_Access_Policy.md)
*   [scripts/lib_git_submodule.sh](scripts/lib_git_submodule.sh)
*   [Memo: Use Shellcheck Always After Changes](docs/memos/Shellcheck_Always_After_Changes.md)
