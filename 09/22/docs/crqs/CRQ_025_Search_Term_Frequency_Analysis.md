# CRQ-025: Search Term Frequency Analysis

*   **Status:** Proposed
*   **Author:** Gemini
*   **Date:** 2025-09-21

## 1. Problem Statement

The existing `search_artistic_keywords.sh` script, while effective at identifying files containing specified keywords, does not provide a mechanism to analyze the frequency of individual matching terms (keywords or their synonyms). This limits our ability to gain insights into which specific artistic or Muse-related concepts are most prevalent within the indexed content, hindering deeper analysis and understanding of the project's thematic landscape.

## 2. Proposed Solution

Enhance the project's search utility (`scripts/lib_search_utils.sh`) to perform a frequency analysis of the matched terms. This will involve modifying the search process to identify and count occurrences of each specific pattern from the `combined_search_patterns.txt` file. A new function will be introduced to output the N most common terms.

## 3. Scope

*   **In Scope:**
    *   Modification of `scripts/lib_search_utils.sh` to add a new function, e.g., `get_top_n_matching_terms(pattern_file, search_dir, n)`.
    *   Modification of `scripts/search_artistic_keywords.sh` to call this new function and present the top N terms.
    *   Updates to `docs/sops/SOP_Artistic_Keyword_Search.md` to document this new functionality.
*   **Out of Scope:**
    *   Changes to the core `grep` search mechanism beyond what is necessary for term identification.
    *   Analysis of term co-occurrence or complex linguistic patterns.

## 4. Implementation Details

### 4.1. Modify `scripts/lib_search_utils.sh`

A new function, `get_top_n_matching_terms`, will be added:

*   `get_top_n_matching_terms(pattern_file, search_dir, n)`:
    *   **Purpose:** Performs a search for all patterns in `pattern_file` within `search_dir`, counts the occurrences of each *specific* pattern, and returns the top `n` most common patterns.
    *   **Mechanism:** This function will likely iterate through each pattern in `pattern_file`. For each pattern, it will run a `grep -o` search (to output only the matching part) within `search_dir`. The results will then be aggregated, counted, sorted by frequency, and the top `n` will be returned.
    *   **Output:** A formatted list of the top N terms and their counts.

### 4.2. Modify `scripts/search_artistic_keywords.sh`

The main script will be updated to:

1.  Call `get_top_n_matching_terms` after the initial search.
2.  Present the results of the frequency analysis to the user.

### 4.3. Update `docs/sops/SOP_Artistic_Keyword_Search.md`

The SOP will be updated to include:

*   A description of the new term frequency analysis capability.
*   Instructions on how to use it (e.g., by passing an argument to `search_artistic_keywords.sh` or by running a separate command).

## 5. Expected Outcomes

*   Ability to quickly identify the most prevalent artistic and Muse-related terms within the project's indexed content.
*   Enhanced analytical capabilities for understanding the project's thematic focus.
*   Improved adherence to the Quality Doctrine by formalizing this new functionality.

## 6. Rollback Plan

To roll back, revert the changes to `scripts/lib_search_utils.sh` and `scripts/search_artistic_keywords.sh`, and update `docs/sops/SOP_Artistic_Keyword_Search.md` accordingly.
