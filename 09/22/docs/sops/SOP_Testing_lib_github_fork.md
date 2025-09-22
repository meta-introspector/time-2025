# SOP: Testing `lib_github_fork_repo` Function

## 1. Purpose

This Standard Operating Procedure (SOP) outlines the steps to execute and verify the integration tests for the `lib_github_fork_repo` function, located in `lib/lib_github_fork.sh`. These tests ensure that the function correctly interacts with the GitHub CLI (`gh`) to fork repositories and handles various scenarios, including non-existent repositories and re-forking.

## 2. Scope

This SOP applies to developers and testers responsible for verifying the functionality of the `lib_github_fork_repo` function and ensuring its correct integration within the project's scripts.

## 3. Prerequisites

*   **GitHub CLI (`gh`):** Must be installed and authenticated with sufficient permissions to fork repositories into the `meta-introspector` organization. It is highly recommended to use a dedicated test GitHub account and organization to avoid unintended forks or rate limiting issues on production accounts.
*   **Project Repository:** The local project repository must be cloned and up-to-date.
*   **`lib/lib_github_fork.sh`:** The `lib_github_fork_repo` function and its dependencies must be present in the `lib/` directory.
*   **`tests/lib/test_lib_github_fork.sh`:** The test script must be present in the `tests/lib/` directory.

## 4. Procedure

### 4.1. Prepare the Test Environment

1.  Ensure your `gh` CLI is authenticated. If not, run `gh auth login` and follow the prompts.
2.  Verify that your authenticated `gh` user has permissions to create repositories within the `meta-introspector` GitHub organization.
3.  **Run Shellcheck on Test Scripts**: Before execution, run `shellcheck` on `lib/lib_github_fork.sh` and `tests/lib/test_lib_github_fork.sh` to ensure script quality. Refer to [Memo: Use Shellcheck Always After Changes](../../docs/memos/Shellcheck_Always_After_Changes.md) for details.
    ```bash
    shellcheck lib/lib_github_fork.sh
    shellcheck tests/lib/test_lib_github_fork.sh
    ```

### 4.2. Execute the Test Script

Navigate to the project root directory and execute the test script:

```bash
./tests/lib/test_lib_github_fork.sh
```

### 4.3. Monitor Test Output

Observe the output of the script. It will provide messages for each test case, indicating whether it passed or failed. Expected output includes:

*   **Test Case 1 (Non-existent repository):** Should report `PASS` as it's expected to fail to fork a non-existent repository.
*   **Test Case 2 (Valid repository):** Should report `PASS` if the fork operation (or handling of an existing fork) is successful. It will also provide a message to manually verify the fork on GitHub.
*   **Test Case 3 (Re-forking):** Should report `PASS` as the function is expected to handle attempts to fork an already forked repository gracefully.

### 4.4. Manual Verification (for Test Case 2)

After Test Case 2, the script will output the name of the forked repository (e.g., `meta-introspector/cli-test-fork-XXXXXXXXXX`). Navigate to your GitHub organization (`https://github.com/meta-introspector`) and confirm that the newly forked repository exists.

### 4.5. Cleanup (Optional)

If a new fork was created during testing and you wish to remove it, you can do so manually via the GitHub UI or using the `gh` CLI:

```bash
gh repo delete meta-introspector/<FORK_NAME> --confirm
```

Replace `<FORK_NAME>` with the actual name of the forked repository from the test output.

## 5. Troubleshooting

*   **Test Case 1 Fails (Unexpected Success):** This indicates an issue with the test logic or an unexpected behavior of `gh repo fork` for non-existent repos. Review the `lib_github_fork_repo` function and the test script.
*   **Test Case 2 Fails:** This usually points to `gh` CLI authentication issues, insufficient GitHub permissions, or a problem with the `lib_github_fork_repo` function itself. Verify your `gh` setup and permissions.
*   **Test Case 3 Fails:** This suggests that the `lib_github_fork_repo` function is not gracefully handling attempts to fork an already existing repository. Review the function's logic.
*   **`gh` Command Not Found:** Ensure the GitHub CLI is correctly installed and accessible in your system's PATH.

## 6. Related Documents

*   `CRQ_032_Refactor_gh_repo_fork_into_lib.md`
*   `lib/lib_github_fork.sh`
*   `scripts/extract_and_vendorize_github_repos.sh`
