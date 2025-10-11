# 3. The `nar-locator` Flake: Canonical Naming and Structure

The `nar-locator` flake, located at `10/11/nar-locator/flake.nix`, builds upon the `nix-store-dump` flake to provide a standardized approach for naming and organizing generated NAR files within a predefined directory structure. This flake is crucial for ensuring discoverability, consistency, and efficient management of NAR artifacts across the project.

## Purpose

The `nar-locator` flake's primary purpose is to:

1.  **Canonical Naming:** Generate a consistent and predictable filename for each NAR based on its original source path.
2.  **Structured Output:** Place the generated NAR files into a logical directory hierarchy, reflecting their type or origin.
3.  **Abstraction:** Further abstract the NAR creation process, allowing other flakes to simply provide a store path and an identifier, and receive a properly named and located NAR in return.

## `lib.locateAndDumpNar` Function

This flake exposes the `lib.locateAndDumpNar` function, which orchestrates the NAR creation and placement.

### Arguments:

*   `storePath` (required): The Nix store path (e.g., `/nix/store/...`) of the item to be archived into a NAR.
*   `originalFilePath` (required): The original, human-readable file path or identifier of the source content. This is used by the `nar-locator` to determine the NAR's canonical name and its category within the output structure.

### How it Works:

The `locateAndDumpNar` function performs the following key steps:

1.  **Category Determination (`getCategoryDir`):**
    *   It analyzes the `originalFilePath` to determine an appropriate category for the NAR. Currently, it categorizes files based on their extension (e.g., `.nix` files go into `nix-files`, `.sh` files into `shell-scripts`, and files containing "Makefile" in their name go into `makefiles`). Files without a recognized extension are placed in `no-extension`, and others in `other`.
    *   This categorization is a simplified implementation of the broader "71 subdirectories" concept, which aims for a highly granular and systematic organization of all project artifacts within an "8d manifold" structure. Future expansions will refine this categorization to include more types and potentially content-based classifications.

2.  **Canonical Filename Generation (`sanitizePath`):**
    *   The `originalFilePath` is sanitized to create a clean, filesystem-friendly `narFileName`. This involves replacing characters like `/`, `.`, and `-` with underscores (`_`) to ensure a valid and consistent filename.
    *   The `.nar` extension is then appended to this sanitized name.

3.  **NAR Creation (via `nixStoreDumpFlake`):**
    *   The function then calls `nixStoreDumpFlake.lib.dumpStorePath`, passing the `storePath` and the newly generated `narFileName`.
    *   This step leverages the core `nix-store --dump` functionality provided by the `nix-store-dump` flake to actually create the NAR file.

4.  **Output Placement:**
    *   The resulting NAR file from `nixStoreDumpFlake` is then copied into a specific location within the `nar-locator`'s output. The target path follows the structure: `09/22/crq-binstore/${categoryDir}/${narFileName}`.
    *   This ensures that all generated NARs are consistently placed within the `09/22/crq-binstore/` directory, organized by their determined category.

## Benefits:

*   **Standardization:** All NARs generated through this flake will adhere to a consistent naming and directory structure.
*   **Discoverability:** It becomes easier to locate specific NARs based on their original file type and canonical name.
*   **Automation:** Facilitates automated processing and analysis of NAR artifacts due to predictable paths.
*   **Future-Proofing:** The structured output lays the groundwork for more advanced content addressing and metadata management, aligning with the "8d manifold" vision for comprehensive artifact organization.
