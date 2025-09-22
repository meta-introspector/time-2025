# SOP: Efficient Task Execution

## Purpose:
This Standard Operating Procedure (SOP) provides guidelines and best practices for enhancing the efficiency and reliability of task execution within the `gemini-cli` workflow. By adhering to these principles, the aim is to minimize errors, streamline agent responses, and optimize tool usage.

## Scope:
This SOP applies to all interactions and task executions performed by the agent using the `gemini-cli` tools.

## Procedure:

### 1. Precise and Informative Agent Responses:
-   **Avoid Redundancy**: Minimize generic acknowledgments (e.g., "Understood," "Got it"). Instead, confirm understanding by rephrasing the request or outlining the immediate next step.
-   **Specific Progress Updates**: When performing multi-step operations, provide concise updates on the current step and what has been achieved.
-   **Clarify Ambiguity**: If an instruction is unclear, ask targeted questions to gain clarity before proceeding.

### 2. Pre-validation for Tool Calls:

#### 2.1. Path Handling:
-   **Always Verify Paths**: Before using any file system tool (e.g., `read_file`, `write_file`, `run_shell_command` with `directory`), ensure the path is correct and absolute. If a relative path is provided by the user, resolve it against the project root.
-   **Check Workspace Directories**: For `run_shell_command` with a `directory` argument, confirm that the specified directory is a valid and registered workspace directory.

#### 2.2. `replace` Tool Usage:
-   **Pre-read File Content**: Before executing `replace`, always use `read_file` to fetch the current content of the target file.
-   **Verify `old_string` Existence**: Search for `old_string` within the read content to confirm its presence and count the occurrences.
-   **Match `expected_replacements`**: If `expected_replacements` is specified, ensure the count of `old_string` occurrences in the file matches this expectation. If not, adjust `old_string` or `expected_replacements` as necessary.
-   **Exact Match**: Emphasize that `old_string` must be an exact literal match, including whitespace and indentation. Provide sufficient context (at least 3 lines before and after) to ensure uniqueness.

### 3. Managing Execution Environments and Dependencies:
-   **Identify Dependencies**: Before running scripts (e.g., Python scripts), identify their dependencies.
-   **Verify Environment**: Check if the necessary executables (e.g., `python3`, `cargo`) are available in the current environment's PATH.
-   **Nix-shell Awareness**: If the project uses `shell.nix`, be aware that tools might need to be run within a `nix-shell` environment. If the agent is not in a `nix-shell`, it should inform the user or request the absolute path to the executable.

### 4. Optimal Task Granularity:
-   **Break Down Complex Tasks**: For broad or complex user requests, propose breaking them down into smaller, more manageable sub-tasks.
-   **Focus on Single Objectives**: Each sub-task should ideally have a single, clear objective to reduce complexity and potential for errors.

### 5. Automated Verification Steps:
-   **Post-Modification Checks**: After making code or configuration changes, automatically run relevant build, linting, or testing commands (e.g., `cargo check`, `npm run lint`, `pytest`).
-   **Git Status Review**: Regularly run `git status` to monitor changes and ensure the repository state is as expected.
-   **Log Review**: Review relevant logs (e.g., `shell.log`, build logs) for errors or unexpected output after executing commands.

## Related Documents:
- [CRQ-016: Submodule Nixification and Flake Refactoring](docs/crqs/CRQ_016_Submodule_Nixification.md)
- [Memo: Use Shellcheck Always After Changes](docs/memos/Shellcheck_Always_After_Changes.md)
- `docs/crqs/CRQ_Enhance_Task_Execution_Efficiency.md`

## Revision History:
- [Date]: Initial Draft
