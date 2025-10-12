# CRQ-XXX: Canonical Functional Reference for File Bucketing

## Title
Establish a Canonical Functional Reference for File Bucketing in Nix

## Status
Open

## Date
October 12, 2025

## Description
This CRQ proposes the creation of a canonical, reusable Nix functional reference (a function or module) for categorizing files based on their metadata, such as file extension and directory path components. This functionality is crucial for various analysis workflows, including the "Grep Workflow with Existing Nix Flakes" (CRQ-XXX), where files need to be grouped before further processing. The goal is to provide a standardized and efficient way to "bucket" files, promoting modularity and reusability across the project.

### Context
Several analysis tasks within the project require processing files based on their characteristics. Currently, such categorization logic might be duplicated or implemented inconsistently across different flakes or modules. A centralized, canonical functional reference for file bucketing will streamline these processes, improve maintainability, and ensure consistency in file categorization.

## Goal
1.  **Define a clear interface:** Establish a well-defined input and output structure for the file bucketing function/module.
2.  **Implement robust categorization:** Develop a function that can categorize a list of file paths by:
    *   File extension.
    *   Directory path components.
    *   (Potentially) other metadata if feasible within pure Nix.
3.  **Ensure reusability:** Design the functional reference to be easily importable and usable by other flakes and modules within the project.
4.  **Adhere to purity:** Implement the bucketing logic as a pure Nix function, relying solely on its inputs and `nixpkgs.lib` functions.

## Proposed Solution / Next Steps
1.  **Design the function/module signature:** Determine the optimal input arguments (e.g., a list of file paths, configuration for bucketing criteria) and the output format (e.g., an attribute set of buckets, where each bucket contains a list of file paths).
2.  **Implement the bucketing logic:** Utilize `nixpkgs.lib` functions such as `lib.lists.groupBy`, `lib.mapAttrs`, `lib.strings.splitString`, `lib.strings.fileExt` (or a custom equivalent if needed) to perform the categorization.
3.  **Create a dedicated module:** Encapsulate the bucketing logic in a new Nix module (e.g., `lib/file-bucketer.nix` or `flakes/file-bucketer/flake.nix`) to make it easily importable.
4.  **Integrate into relevant workflows:** Once implemented, integrate this canonical reference into workflows like the "Grep Workflow with Existing Nix Flakes" (CRQ-XXX).

## Impact
*   **Standardized file categorization:** Ensures consistent grouping of files across the project.
*   **Improved code reusability:** Reduces duplication of bucketing logic.
*   **Enhanced maintainability:** Centralizes file categorization logic, making it easier to update and improve.
*   **Facilitates complex analysis:** Provides a foundational component for more sophisticated file analysis workflows.

## Related CRQs
*   CRQ-XXX: Grep Workflow with Existing Nix Flakes
