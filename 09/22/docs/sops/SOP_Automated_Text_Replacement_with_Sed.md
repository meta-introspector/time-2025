# SOP: Automated Text Replacement with Sed

## 1. Purpose

This Standard Operating Procedure (SOP) provides guidelines for performing automated text replacements within files using the `sed` (stream editor) command. This is particularly useful for refactoring code, updating configurations, or applying consistent changes across multiple files.

## 2. Scope

This SOP applies to all text-based files within the project that require systematic modifications. It is intended for developers and contributors who need to perform precise and repeatable text replacements.

## 3. Prerequisites

*   Basic understanding of command-line interfaces.
*   Familiarity with regular expressions (regex) for advanced patterns.
*   Access to a Unix-like environment with `sed` installed.

## 4. Procedure: Performing Automated Text Replacement

### 4.1. Basic `sed` Replacement

The most common form of `sed` replacement uses the `s` (substitute) command:

```bash
sed -i 's/old_string/new_string/g' <file_path>
```

*   `-i`: Edits the file in place. On some systems (e.g., macOS), you might need to use `sed -i ''` or `sed -i.bak` to create a backup.
*   `s`: The substitute command.
*   `old_string`: The text or regular expression to search for.
*   `new_string`: The text to replace `old_string` with.
*   `g`: (Global) Replaces all occurrences of `old_string` on each line. If omitted, only the first occurrence on each line is replaced.
*   `<file_path>`: The path to the file to modify.

### 4.2. Important Considerations for `old_string` and `new_string`

When using `sed` for refactoring, especially with multi-line or context-sensitive replacements, precision is key:

*   **Exact Literal Match:** The `old_string` must be an exact literal match (or a precise regular expression) of the text you intend to replace, including all whitespace, indentation, and newlines. Even a single extra space or a different newline character can cause the replacement to fail.
*   **Context is Crucial:** For complex refactoring, include several lines of surrounding context in your `old_string` to ensure that `sed` targets the correct instance of the text. This minimizes the risk of unintended replacements.
*   **Escaping Special Characters:** If `old_string` or `new_string` contain `sed` delimiters (e.g., `/`), you must escape them with a backslash (`\/`) or choose a different delimiter (e.g., `sed -i 's|old_string|new_string|g'`).
*   **Multi-line Replacements:** `sed` primarily operates line by line. For true multi-line replacements, you might need more advanced `sed` scripting (e.g., using the `N` command to append the next line to the pattern space) or consider tools like `perl` or `awk` which handle multi-line patterns more naturally.

### 4.3. Generating `sed` Scripts for Refactoring

For a series of complex refactoring operations, it is recommended to create a dedicated `sed` script. This script can contain multiple `sed` commands, allowing for a repeatable and auditable refactoring process.

*   **Example `refactor_script.sh`:**
    ```bash
    #!/usr/bin/env bash

    # Apply replacements to file1.sh
    sed -i 's/old_function_call/new_function_call/g' scripts/file1.sh

    # Apply a more complex replacement to config.ini
    sed -i '/^\['section\]/{n;s/key=value/key=new_value/}' config.ini
    ```

## 5. Troubleshooting

*   **"No such file or directory"**: Double-check the `file_path` provided to `sed`.
*   **No replacement occurs**: The `old_string` did not match exactly. Verify whitespace, indentation, and special characters. Use `grep -F "old_string" <file_path>` to confirm the exact string content.
*   **Unintended replacements**: The `old_string` pattern was too broad. Refine the `old_string` to include more context or use more precise regular expressions.

## 6. Related Documentation

*   [CRQ-016: Submodule Nixification and Flake Refactoring](docs/crqs/CRQ_016_Submodule_Nixification.md)
*   [Memo: Use Shellcheck Always After Changes](docs/memos/Shellcheck_Always_After_Changes.md)
*   [scripts/lib_git_submodule.sh](scripts/lib_git_submodule.sh)
*   [Git Access Policy](docs/standards/Git_Access_Policy.md)
