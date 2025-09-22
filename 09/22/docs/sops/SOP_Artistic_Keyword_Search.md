# SOP: Artistic Keyword Search

*   **ID:** SOP-009
*   **Author:** Gemini
*   **Status:** Draft
*   **Related CRQ:** CRQ-021

## 1. Purpose

This SOP documents the use of the `search_artistic_keywords.sh` script, a tool designed to scan the project's `index/` directory for references to the official artistic keywords (defined in the Artistic Policy Framework) and Muse-related keywords.

## 2. Scope

This procedure is for any contributor who wishes to find existing indexed files that may relate to the project's creative concepts.

## 3. Procedure

### 3.1. Running the Script

To execute the search, run the following command from the project root directory:

```bash
bash scripts/search_artistic_keywords.sh [--top-n N]
```

### 3.2. Script Actions

The `search_artistic_keywords.sh` script now utilizes functions from `scripts/lib_search_utils.sh` to perform its actions.

*   **Default Behavior (without `--top-n`):**
    1.  **Initialize:** Determines the project root and sources `scripts/lib_search_utils.sh`.
    2.  **Define Keywords:** Uses a combined list of artistic and Muse-related keywords and their synonyms from `scripts/combined_search_patterns.txt`.
    3.  **Ensure Output Directory:** Calls `ensure_output_dir_exists` to ensure `index/art/` exists.
    4.  **Write Header:** Calls `write_output_header` to write a standardized header to `index/art/artistic_references.md`.
    5.  **Perform Search:** Calls `perform_grep_search` to run a case-insensitive `grep` search across all files and subdirectories within `index/` using the patterns from the combined file.
    6.  **Populate Results:** The `perform_grep_search` function populates `index/art/artistic_references.md` with results or a "no references found" message.

*   **Term Frequency Analysis (`--top-n N`):**
    If the `--top-n N` option is provided, the script will perform a term frequency analysis instead of writing all matches to the `artistic_references.md` file. It will call the `get_top_n_matching_terms` function.

### 3.3. Reviewing the Output

The results of a standard search can be reviewed by opening the generated file:

`/index/art/artistic_references.md`

### 3.4. Term Frequency Analysis

To get the N most common matching terms, run the script with the `--top-n` option, specifying the number of top terms you wish to see:

```bash
bash scripts/search_artistic_keywords.sh --top-n 10
```

This command will output the top 10 most frequently occurring terms directly to the console, along with their counts.

### 3.5. Script Quality Assurance

Before executing `scripts/search_artistic_keywords.sh`, always run `shellcheck` on it and its dependencies (`scripts/lib_search_utils.sh`) to ensure code quality and catch potential errors. Refer to [Memo: Use Shellcheck Always After Changes](../../docs/memos/Shellcheck_Always_After_Changes.md) for details.

```bash
shellcheck scripts/search_artistic_keywords.sh
shellcheck scripts/lib_search_utils.sh
```
