# CRQ-020: Automated Solution Discovery and Vendorization

## 1. Problem Statement

As the project grows, identifying and integrating external solutions (libraries, tools, code snippets) from sources like GitHub, Cargo (Rust crates), and Nixpkgs becomes increasingly complex and time-consuming. Manual discovery and vendorization processes are prone to inconsistencies, security vulnerabilities, and lack of reproducibility. There is a need for an automated, auditable, and standardized workflow for discovering relevant solutions and integrating them into the project's `vendor/nix/` ecosystem.

## 2. Proposed Solution

Develop a comprehensive system for automated solution discovery and vendorization, integrated with Nix and adhering to existing project SOPs. This system will consist of:

1.  **Solution Discovery Script**: A script (`scripts/discover_and_vendorize.sh`) capable of searching GitHub, Cargo, and Nixpkgs for relevant solutions based on keywords or criteria.
2.  **Automated Vendorization**: The script will automate the process of forking (if from GitHub) and integrating discovered solutions under the `vendor/nix/` directory, following the `SOP_Vendorize_And_Fork_Submodule.md` and other relevant SOPs.
3.  **Standard GitHub Utility Library**: Create or extend a standard utility library (`scripts/lib_github.sh`) for common GitHub operations (e.g., repository listing, forking, API calls) to ensure consistent and secure `gh` usage.
4.  **Nix Integration**: Provide Nix-native ways to invoke and manage these discovery and vendorization processes, potentially through dedicated `flake.nix` outputs or `nix run` commands.
5.  **Documentation**: Document the entire process, including how `gh` usage and authentication are handled, and create a standard flake for GitHub operations.

## 3. Scope

### In Scope
*   Creating this CRQ document.
*   Developing `scripts/discover_and_vendorize.sh`.
*   Implementing search functionality for GitHub, Cargo, and Nixpkgs.
*   Automating the vendorization process under `vendor/nix/`.
*   Creating/extending `scripts/lib_github.sh` for standard GitHub operations.
*   Defining Nix integration points (e.g., `flake.nix` outputs, `nix run` commands).
*   Documenting `gh` usage and authentication within the system.
*   Creating a standard flake for GitHub operations.

### Out of Scope
*   Developing a full-fledged search engine or package manager.
*   Automated code modification or integration beyond basic vendorization.
*   Handling non-GitHub, Cargo, or Nixpkgs sources (initially).

## 4. Technical Details

*   **Tools**: `bash`, `gh` (GitHub CLI), `jq`, `curl` (for Cargo/Nixpkgs APIs), `nix`.
*   **GitHub Operations**: Leverage `gh` CLI for repository listing, forking, and other API interactions. Authentication will follow the secure credential handling mechanisms defined in CRQ-019.
*   **Cargo Search**: Utilize `curl` to query the Cargo registry API (e.g., `https://crates.io/api/v1/crates`).
*   **Nixpkgs Search**: Utilize `nix search` or query Nixpkgs metadata directly.
*   **Vendorization**: Integrate with existing `scripts/vendorize_and_fork_submodule.sh` and `SOP_Vendorize_And_Fork_Submodule.md`.
*   **Nix Flake for GitHub Operations**: A dedicated `flake.nix` (e.g., `flakes/github-ops/flake.nix`) that provides a `devShell` with `gh` and other necessary tools, and potentially outputs for specific GitHub-related tasks.

## 5. Testing Plan

1.  Verify that the search script correctly identifies relevant solutions from all specified sources.
2.  Test the automated vendorization process for GitHub repositories, ensuring correct forking and submodule integration.
3.  Verify that `gh` usage is secure and authenticated as per CRQ-019.
4.  Ensure Nix integration points function as expected.

## 6. Rollback Plan

Manual removal of any incorrectly vendorized repositories or forks.

## 7. Future Considerations

*   Integration with other package managers or code hosting platforms.
*   Automated dependency analysis and compatibility checks.
*   Continuous monitoring for updates to vendorized solutions.

## 8. Approval

[ ] Approved by: [Name]
[ ] Date: [Date]
