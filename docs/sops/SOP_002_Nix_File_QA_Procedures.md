# SOP-002: Nix File Quality Assurance Procedures

## Title
Nix File Quality Assurance Procedures

## Version
1.0

## Date
October 3, 2025

## Purpose
This Standard Operating Procedure (SOP) outlines the procedures for conducting Quality Assurance (QA) on Nix files within the project. The goal is to ensure the correctness, buildability, and adherence to established standards for all Nix expressions, flakes, and derivations, thereby maintaining a robust and reproducible development environment.

## Scope
This SOP applies to all `.nix` files located in the main repository and its submodules, including `flake.nix`, `default.nix`, module definitions, and package expressions.

## Responsibilities
*   **QA Team:** Responsible for executing the procedures outlined in this SOP, reporting findings, and collaborating with development teams to resolve issues.
*   **Development Team:** Responsible for addressing reported issues and ensuring their Nix code adheres to project standards.

## Procedures

### 1. Syntax and Formatting Checks
*   **Action:** Regularly run `nixpkgs-fmt --check .` across the entire project codebase.
*   **Tool:** `nixpkgs-fmt`
*   **Frequency:** As part of pre-commit hooks, and during CI/CD pipelines.
*   **Expected Result:** No formatting errors reported. All Nix files conform to `nixpkgs-fmt` standards.
*   **Troubleshooting:** If errors are reported, run `nixpkgs-fmt .` to automatically fix formatting, then re-check.

### 2. Flake Evaluation & Instantiation
*   **Action:**
    *   For the root flake: Execute `nix flake check` from the project root.
    *   For submodule flakes: Navigate to each submodule directory containing a `flake.nix` and execute `nix flake check`.
    *   For individual Nix expressions: Use `nix eval --raw -f <file.nix>` or `nix-instantiate <file.nix>` to verify specific files.
*   **Tool:** `nix` CLI
*   **Frequency:** During CI/CD pipelines, and as needed for specific changes.
*   **Expected Result:** All flakes and expressions evaluate and instantiate without errors. Outputs are consistent with expectations.
*   **Troubleshooting:** Investigate reported evaluation errors (e.g., syntax errors, missing variables, infinite recursion).

### 3. Derivation Buildability
*   **Action:**
    *   For packages defined in flakes: Execute `nix build .#<package-name>` for all critical packages.
    *   For specific derivations: Execute `nix-build <derivation-path>`.
    *   Test all default packages and applications defined in `flake.nix` outputs.
*   **Tool:** `nix` CLI
*   **Frequency:** During CI/CD pipelines, and before major releases.
*   **Expected Result:** All specified derivations build successfully without runtime errors.
*   **Troubleshooting:** Analyze build logs for compilation errors, missing dependencies, or incorrect build phases.

### 4. Development Environment (`devShell`) Verification
*   **Action:** In directories with `flake.nix` or `shell.nix`, execute `nix develop` (or `nix-shell`) to enter the development environment.
*   **Tool:** `nix` CLI
*   **Frequency:** Periodically, and when `devShell` configurations are updated.
*   **Expected Result:** The `devShell` activates without errors, and all expected tools and dependencies are available on the PATH.
*   **Troubleshooting:** Check `shell.nix` or `flake.nix` for incorrect package references or environment variable settings.

### 5. Dependency Management & Purity Checks
*   **Action:**
    *   Review `flake.lock` files for consistency and to ensure all inputs are locked to specific revisions (especially for GitHub URLs).
    *   Manually inspect Nix files for impure constructs (e.g., `builtins.fetchTarball` without a `sha256`, direct access to `/etc`).
*   **Tool:** `git`, manual inspection.
*   **Frequency:** During code reviews, and when `flake.lock` files are updated.
*   **Expected Result:** `flake.lock` files are up-to-date and consistent. No unintended impure builds are introduced.
*   **Troubleshooting:** Use `nix flake update` to refresh `flake.lock`. Address impure constructs by providing explicit hashes or using pure alternatives.

### 6. Cross-System Compatibility (if applicable)
*   **Action:** If the project targets multiple systems (e.g., `aarch64-linux`, `x86_64-linux`), execute `nix flake check --system <target-system>` and `nix build .#<package-name> --system <target-system>` for each target system.
*   **Tool:** `nix` CLI
*   **Frequency:** During CI/CD pipelines for multi-platform projects.
*   **Expected Result:** Builds and evaluations succeed on all supported systems.
*   **Troubleshooting:** Investigate system-specific build failures or evaluation errors.

### 7. Documentation & Readability Review
*   **Action:** Conduct periodic manual reviews of Nix files to ensure clear comments, meaningful variable names, and adherence to project-specific coding conventions.
*   **Tool:** Manual review.
*   **Frequency:** During code reviews and periodic quality audits.
*   **Expected Result:** Nix files are well-documented, understandable, and maintainable.
*   **Troubleshooting:** Provide feedback to developers on areas for improvement in documentation and readability.

## Reporting
*   All findings, including pass/fail status, error logs, and troubleshooting steps, shall be documented in the QA report for each testing cycle.
*   Critical issues must be reported immediately to the development team for resolution.

## Related Documents
*   CRQ-048: Nix File Quality Assurance Plan
*   SOP-001: Nix Flake GitHub URL Policy
