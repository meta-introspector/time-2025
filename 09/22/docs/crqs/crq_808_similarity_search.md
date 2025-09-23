# CRQ-808: Similarity Search using N-Gram Index

- **Status:** Proposed
- **Requester:** User
- **Date:** 2025-09-23

## 1. Problem

The project currently lacks a mechanism for performing content-based similarity searches across the codebase and documentation. This makes it difficult to:

- Identify and refactor duplicated or similar code snippets.
- Discover relevant documentation or examples related to a piece of code.
- Analyze the conceptual overlap between different modules or scripts.

Initial work has begun on this, as evidenced by the presence of an `ngram_index.json` file, but the process needs to be formalized, documented, and completed.

## 2. Proposed Solution

Implement a Bag-of-Words (BoW) similarity search capability by creating a comprehensive n-gram index of specified project directories. This involves:

1.  **Creating a script** that systematically processes target files.
2.  **Generating n-grams** of various sizes for the content of each file.
3.  **Counting the frequency** of each n-gram.
4.  **Storing the results** in a structured JSON file (`ngram_index.json`) that maps files to their n-gram frequency distributions.

This index will serve as the foundation for future tools to calculate similarity scores between files.

## 3. Scope

### In Scope

-   **Indexing Script:** Development of a robust script to generate the n-gram index.
-   **Target Directories:** The initial indexing will target the following directories within the project root (`/data/data/com.termux.nix/files/home/pick-up-nix2/`):
    -   `scripts/`
    -   `docs/`
-   **N-Gram Sizes:** The index will be built using the following prime n-gram sizes to capture a varied range of token sequences: 1, 2, 3, 5, 7, 11, 13, 19, 23.
-   **Output:** A single `ngram_index.json` file containing the n-gram counts for all processed files.

### Out of Scope

-   A user-facing search interface or API.
-   Real-time or automated re-indexing on file changes.
-   The implementation of the actual similarity comparison algorithm (e.g., cosine similarity); this CRQ covers only the index creation.

## 4. Technical Details

-   The indexing script will be designed for portability and reusability.
-   It will recursively scan the target directories.
-   For each file, it will read the content, convert it to lowercase, and tokenize it.
-   It will then generate n-grams of the specified sizes and count their occurrences.
-   The final output will be a JSON object where keys are file paths and values are objects containing the n-gram counts.

## 5. Testing Plan

-   The script will be tested to ensure it runs without errors on the target directories.
-   The generated `ngram_index.json` will be manually inspected for a small set of files to verify the correctness of the n-gram generation and counting.
-   A separate validation script may be created to check the structure and integrity of the JSON output.

## 6. Rollback Plan

-   In case of issues, the `ngram_index.json` file can be deleted.
-   The script created for this task can be removed or reverted.
