# CRQ-024: Refactor Search Keywords Script

*   **Status:** Proposed
*   **Author:** Gemini
*   **Date:** 2025-09-21

## 1. Problem Statement

The `scripts/search_artistic_keywords.sh` script, while functional, contains inline logic for common tasks such as path resolution, directory creation, header writing, and search execution. This approach reduces reusability, makes the script less modular, and does not fully adhere to the "Do Not Repeat Yourself (DRY)" principle. As the project grows, maintaining such monolithic scripts becomes increasingly challenging.

## 2. Proposed Solution

Refactor the `scripts/search_artistic_keywords.sh` script by extracting common functionalities into a new, shared Bash library file (`scripts/lib_search_utils.sh`). The main script will then be updated to utilize these reusable functions, improving its modularity, readability, and maintainability.

## 3. Scope

*   **In Scope:**
    *   Creation of a new Bash library file: `scripts/lib_search_utils.sh`.
    *   Modification of `scripts/search_artistic_keywords.sh` to source and use functions from `lib_search_utils.sh`.
    *   Updates to `docs/sops/SOP_Artistic_Keyword_Search.md` to reflect the new script structure and the dependency on the library file.
*   **Out of Scope:**
    *   Refactoring of any other scripts at this time.
    *   Changes to the core search logic (i.e., the `grep` command itself).

## 4. Implementation Details

### 4.1. Create `scripts/lib_search_utils.sh`

This new file will contain the following reusable Bash functions:

*   `get_project_root()`:
    *   **Purpose:** Determines and returns the absolute path to the project's root directory.
    *   **Usage:** `PROJECT_ROOT=$(get_project_root)`
*   `ensure_output_dir_exists(output_dir)`:
    *   **Purpose:** Creates the specified directory if it does not already exist.
    *   **Usage:** `ensure_output_dir_exists "${OUTPUT_DIR}"`
*   `write_output_header(output_file, script_name, search_description)`:
    *   **Purpose:** Writes a standardized header to the specified output file.
    *   **Parameters:** `output_file` (path to the output file), `script_name` (name of the calling script), `search_description` (a brief description of what was searched).
    *   **Usage:** `write_output_header "${OUTPUT_FILE}" "search_artistic_keywords.sh" "artistic and Muse-related"`
*   `perform_grep_search(pattern_file, search_dir, output_file)`:
    *   **Purpose:** Executes a case-insensitive, recursive `grep` search using patterns from a file and appends results to an output file. Handles success/failure messages.
    *   **Parameters:** `pattern_file` (path to the file containing search patterns), `search_dir` (directory to search within), `output_file` (path to the file to write results to).
    *   **Usage:** `perform_grep_search "${PATTERN_FILE}" "${SEARCH_DIR}" "${OUTPUT_FILE}"`

### 4.2. Modify `scripts/search_artistic_keywords.sh`

The main script will be modified as follows:

1.  **Remove:**
    *   The inline `PROJECT_ROOT` calculation.
    *   The inline `mkdir -p` call for `OUTPUT_DIR`.
    *   The inline `printf` calls for writing the header.
    *   The `if/else` block containing the `grep` command and result reporting.
2.  **Add:**
    *   A `source` command to include `scripts/lib_search_utils.sh` (e.g., `source "$(get_project_root)/scripts/lib_search_utils.sh"`).
    *   Calls to the new functions:
        *   `PROJECT_ROOT=$(get_project_root)`
        *   `ensure_output_dir_exists "${OUTPUT_DIR}"`
        *   `write_output_header "${OUTPUT_FILE}" "search_artistic_keywords.sh" "artistic and Muse-related"`
        *   `perform_grep_search "${PATTERN_FILE}" "${SEARCH_DIR}" "${OUTPUT_FILE}"`
3.  **Update Internal Documentation:** Adjust comments to reflect the new modular structure.

## 5. Expected Outcomes

*   Improved modularity and readability of `scripts/search_artistic_keywords.sh`.
*   Enhanced reusability of common Bash functionalities across the project.
*   Better adherence to the DRY principle.
*   Easier maintenance and debugging of search-related scripts.

## 6. Rollback Plan

The changes involve creating a new file and modifying an existing one. To roll back, simply revert the changes to `scripts/search_artistic_keywords.sh` and delete `scripts/lib_search_utils.sh`.
