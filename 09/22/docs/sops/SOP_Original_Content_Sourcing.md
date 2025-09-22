# SOP: Original Content Sourcing and Placement

## 1. Purpose

This Standard Operating Procedure (SOP) outlines the guidelines for integrating original content (i.e., projects or repositories not forked from external sources) into the project's `sources/github/meta-introspector/<repo_name>` directory structure. This ensures consistency, proper attribution, and clear distinction from vendorized or forked external dependencies.

## 2. Scope

This SOP applies to all new projects, tools, or content developed internally by the `meta-introspector` organization that are intended to be part of the main project, and are not direct forks of external repositories.

## 3. Procedure

### 3.1. Project Creation

1.  **Create the new Git repository** under the `meta-introspector` GitHub organization.
2.  **Initialize the repository** with a `README.md`, `LICENSE`, and any initial project files.

### 3.2. Local Placement

1.  **Clone the new repository** into the designated `sources/github/meta-introspector/` directory within the main project's working tree.
    ```bash
    git clone https://github.com/meta-introspector/<repo_name> sources/github/meta-introspector/<repo_name>
    ```
    *Replace `<repo_name>` with the actual name of your new repository.*

    **Note on Shell Scripts**: If you create any helper shell scripts to automate this process, remember to run `shellcheck` on them to ensure code quality. Refer to [Memo: Use Shellcheck Always After Changes](../../docs/memos/Shellcheck_Always_After_Changes.md) for details.

### 3.3. Integration into Nix Flake (if applicable)

1.  **Add the new source as an input** to the main project's `flake.nix` (or a relevant sub-flake).
    ```nix
    # flake.nix example
    inputs.<repo_name> = {
      url = "github:meta-introspector/<repo_name>";
      # Optionally, specify a specific ref or rev
      # ref = "main";
      # rev = "<commit_hash>";
    };
    ```
2.  **Reference the input** within your Nix expressions as needed.

### 3.4. Documentation

1.  **Create a `README.md`** within the new repository that clearly describes its purpose, usage, and any relevant build instructions.
2.  **Update relevant project documentation** (e.g., `docs/crqs/`, `docs/sops/`, `docs/tutorials/`) to reference this new original content as appropriate.

## 4. Related Documents

*   [CRQ-020: Automated Solution Discovery and Vendorization](docs/crqs/CRQ_020_Automated_Solution_Discovery_and_Vendorization.md)
*   [SOP: Managing External Nix Dependencies with Absolute Git References](docs/sops/SOP_Submodule_Nixification.md) (This SOP will be updated to reflect the new dependency management strategy.)
