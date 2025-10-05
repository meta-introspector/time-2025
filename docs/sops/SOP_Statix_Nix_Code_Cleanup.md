# SOP-Statix-Nix-Code-Cleanup: Standard Operating Procedure for Statix Nix Code Cleanup

## 1. Purpose
This Standard Operating Procedure (SOP) outlines the process for systematically cleaning up Nix code across the project using the `statix` linter. Adhering to this SOP ensures consistent code quality, readability, maintainability, and compliance with Nix best practices, as detailed in [CRQ-076: Statix Nix Code Cleanup](../crqs/CRQ_076_Statix_Cleanup.md).

## 2. Scope
This SOP applies to all Nix files within the project repository, including those within submodules.

## 3. Prerequisites
- A working Nix development environment.
- Git is installed and configured.
- The `statix` linter is available (typically via `nix run nixpkgs#statix` or within the project's `devShell`).

## 4. Procedure

### 4.1. Generating Statix Output
To identify Nix code issues, generate a `statix` report for the entire project:

1.  Ensure your Git working directory is clean (no unstaged or uncommitted changes, especially in Nix files).
2.  Run the `lint-nix` Make target from the project root:
    ```bash
    make lint-nix
    ```
3.  This command will execute `statix check .` across the project and redirect its output to `statix_output.txt`.

### 4.2. Interpreting Statix Output
Open `statix_output.txt` to review the reported issues. `statix` categorizes issues as:
-   `[E00] Error`: Critical syntax errors preventing Nix evaluation.
-   `[Wxx] Warning`: Stylistic suggestions, deprecated usage, or potential improvements.

### 4.3. Fixing Statix Issues (Phased Approach)
Follow the phased approach defined in [CRQ-076: Statix Nix Code Cleanup](../crqs/CRQ_076_Statix_Cleanup.md):

#### Phase 1: Critical Error Resolution (`[E00] Error`)
1.  **Identify**: Locate all `[E00] Error` entries in `statix_output.txt`.
2.  **Fix**: For each identified file, manually correct the Nix syntax error. This may involve adding missing braces, parentheses, correcting attribute set definitions, or resolving other parsing issues.
3.  **Verify**: After fixing an error in a file, re-run `statix check` specifically on that file to confirm the error is resolved:
    ```bash
    nix run github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify#statix -- check <path/to/fixed/file.nix>
    ```
    (For submodules, navigate to the submodule's root before running the command, or adjust the path accordingly).
4.  **Commit**: Once all `[E00] Error`s are resolved, commit your changes with a descriptive message (e.g., "Fix: Resolve critical statix errors in <file.nix>"). If changes are within a submodule, follow the submodule commit procedure (Section 4.4).

#### Phase 2: Assignment and Expression Simplification (`[W03]`, `[W04]`, `[W08]`, `[W10]`, `[W19]`, `[W07]`, `[W01]`)
1.  **Identify**: Focus on warnings related to assignment simplification, redundant parentheses, empty patterns, eta-reduction, and unnecessary boolean comparisons.
2.  **Fix**: Apply the suggested changes (e.g., use `inherit`, remove unnecessary parentheses, use `_` for unused arguments, simplify `if` expressions).
3.  **Verify**: Re-run `statix check` on the modified files to ensure warnings are resolved and no new issues are introduced.
4.  **Commit**: Commit your changes with a descriptive message (e.g., "Refactor: Simplify Nix expressions based on statix warnings"). Follow the submodule commit procedure if applicable.

#### Phase 3: Modernization and Best Practices (`[W13]`, `[W15]`, `[W20]`, `[W02]`, `[W12]`)
1.  **Identify**: Address warnings related to deprecated builtins, `groupBy` usage, repeated keys, useless `let-in` expressions, and unquoted URI expressions.
2.  **Fix**: Implement the recommended modernizations and best practices.
3.  **Verify**: Re-run `statix check` on the modified files.
4.  **Commit**: Commit your changes (e.g., "Chore: Modernize Nix code per statix best practices"). Follow the submodule commit procedure if applicable.

### 4.4. Committing Changes in Submodules
When fixing issues in files located within a Git submodule (e.g., `vendor/nix/mach-nix/flake.nix`):

1.  **Navigate to Submodule**: `cd <path/to/submodule/root>` (e.g., `cd 09/26/synapse-system/vendor/nix/mach-nix`).
2.  **Stage Changes**: `git add <modified_file(s)>`.
3.  **Commit in Submodule**: `git commit -m "Fix: <Descriptive message for submodule changes>"`.
4.  **Navigate to Parent**: `cd ..` (or `cd <path/to/parent/submodule/root>`).
5.  **Stage Submodule Update**: `git add <submodule_directory>` (e.g., `git add vendor/nix/mach-nix`). This records the new commit SHA of the submodule.
6.  **Commit Parent**: `git commit -m "Update <submodule_name> with <descriptive_message>"`.
7.  **Repeat for Superproject**: If the parent was also a submodule, repeat steps 4-6 until you reach the superproject root.

## 5. Verification
After completing all phases, run `make lint-nix` again from the project root. The `statix_output.txt` file should ideally be empty or contain only acceptable warnings (if any are explicitly waived).

## 6. Related Documents
-   [CRQ-076: Statix Nix Code Cleanup](../crqs/CRQ_076_Statix_Cleanup.md)
-   `Makefile` (for `lint-nix` target definition)
-   `statix_output.txt` (generated report)
