# SOP: Searching the Project Index

## 1. Purpose

This Standard Operating Procedure (SOP) outlines the method for efficiently searching for terms within the project's `index/` directory. The `index/` directory contains various categorized lists of files, making it a valuable resource for quickly locating relevant information.

## 2. Scope

This SOP applies to all developers and contributors who need to search for specific terms or patterns within the project's indexed files.

## 3. Prerequisites

*   A local clone of the project repository.
*   The `scripts/search_index.sh` script must be present and executable.

## 4. Procedure: Searching the Project Index

### 4.1. Using the `search_index.sh` Script

The `scripts/search_index.sh` script provides a convenient way to search for a given term within the `index/` directory.

1.  **Navigate to the Project Root (Recommended):**
    Ensure you are in the root directory of your `pick-up-nix` project.

2.  **Execute the Script:**
    Run the `search_index.sh` script, providing the term you want to search for as an argument.

    ```bash
    ./scripts/search_index.sh <search_term>
    ```

    *   `<search_term>`: The word or pattern you are looking for (e.g., `flake`, `git`, `nix`).

    *   **Example:** To find all mentions of "flake" in the index files:
        ```bash
        ./scripts/search_index.sh flake
        ```

    *   **Expected Output:**
        The script will display lines from files within the `index/` directory that contain the `search_term`, along with the filename.

        ```
        Searching for 'flake' in index/ directory...
        index/file_nix.txt:./flake.nix
        index/file_nix.txt:./vendor/nix/nixtract/flake.nix
        index/file_md.txt:./docs/FLAKE_TUTORIAL.md
        ```

## 5. Troubleshooting

*   **"Usage: ..." error:** Ensure you provide a search term as an argument to the script.
*   **No output:** If the script runs but produces no output, it means the `search_term` was not found in any files within the `index/` directory.
*   **Script not found/executable:** Ensure the path to `search_index.sh` is correct and that it has execute permissions (`chmod +x scripts/search_index.sh`).

## 6. Related Documentation

*   [CRQ-016: Submodule Nixification and Flake Refactoring](docs/crqs/CRQ_016_Submodule_Nixification.md)
*   [Memo: Use Shellcheck Always After Changes](docs/memos/Shellcheck_Always_After_Changes.md)
*   [scripts/search_index.sh](scripts/search_index.sh)
