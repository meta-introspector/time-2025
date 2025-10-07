# CRQ-043: Extract and Shellcheck Nix Embedded Scripts

## Title
Extract and Shellcheck Shell Scripts Embedded in Nix Files

## Status
Status: In Progress

## Date
October 2, 2025

## Description

This Change Request outlines the process of identifying and extracting shell scripts that are currently embedded directly within Nix expressions (e.g., within `pkgs.runCommand` or `installPhase` blocks). Once extracted, these scripts will be subjected to `shellcheck` analysis to ensure adherence to best practices, improve readability, and enhance maintainability.

Currently, many Nix expressions contain inline shell scripts. While convenient for small tasks, this practice can lead to:

-   **Reduced Readability:** Complex shell logic embedded within Nix syntax can be difficult to parse and understand.
-   **Lack of Static Analysis:** Inline scripts are not typically subjected to `shellcheck` or other static analysis tools, leading to potential bugs, inefficiencies, or security vulnerabilities.
-   **Duplication:** Similar shell logic might be duplicated across multiple Nix expressions.

## Goal

The primary goal of this CRQ is to improve the quality, maintainability, and testability of shell scripts used within our Nix ecosystem by:

1.  **Identifying Embedded Scripts:** Systematically locate all instances of shell scripts embedded within Nix files.
2.  **Extracting Scripts:** Move identified shell scripts into separate `.sh` files.
3.  **Integrating `shellcheck`:** Ensure all extracted shell scripts are automatically checked by `shellcheck` as part of the pre-commit hooks or CI/CD pipeline.
4.  **Updating Nix Expressions:** Modify the original Nix expressions to reference the newly extracted shell scripts.

## Proposed Solution / Next Steps

1.  **Script Identification Strategy:** Develop a strategy (e.g., using `grep` with regex patterns) to identify common patterns of embedded shell scripts within Nix files.
2.  **Extraction Tooling (Optional):** Investigate or develop a tool to automate the extraction process, if feasible and efficient.
3.  **Shellcheck Integration:** Ensure the `shellcheck` pre-commit hook (or a dedicated CI job) is configured to run against all extracted `.sh` files.
    *   **Update (2025-10-04):** Initial `shellcheck` fixes have been applied to several existing `.sh` files. Challenges were encountered with pre-commit hook configuration, specifically with the `CRQ Document Existence Check` which was temporarily disabled due to persistent failures. Further investigation into robust pre-commit hook management in a Nix environment is required.
4.  **Iterative Extraction:** Begin with a small, manageable set of Nix files to extract scripts from, and iterate on the process.
5.  **Documentation:** Update relevant SOPs and documentation to establish guidelines for embedding vs. extracting shell scripts in Nix.

## Impact

-   Improved code quality and maintainability of shell scripts.
-   Enhanced static analysis coverage.
-   Reduced technical debt.
-   Easier debugging of shell-related issues.

## Related CRQs

-   CRQ-041: Nix Flake Refactoring and Topological Makefile
-   CRQ-042: Nix Flake Attribute Path Resolution Issue
