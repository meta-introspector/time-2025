# CRQ-048: Nix File Quality Assurance Plan

## Title
Nix File Quality Assurance Plan

## Status
Open

## Date
October 3, 2025

## Description
Establishing a comprehensive Quality Assurance (QA) plan for all Nix files within the project to ensure their correctness, buildability, and adherence to established standards. This plan aims to integrate various tools and methodologies to maintain a robust and reproducible development environment.

### Context
As the project heavily relies on Nix for reproducibility and dependency management, a systematic approach to testing and validating Nix files is crucial. This CRQ outlines a detailed QA plan to proactively identify and resolve issues related to Nix expressions, flakes, and derivations.

## Goal
1.  Ensure all Nix files are syntactically correct and semantically valid.
2.  Verify that all Nix flakes and derivations are buildable and produce expected outputs.
3.  Promote consistent formatting and adherence to Nix best practices across the codebase.
4.  Enhance the overall reliability and maintainability of the Nix infrastructure.

## Proposed Solution / Next Steps

### Tools & Methodologies:
*   **Nix Built-in Commands:** `nix flake check`, `nix eval`, `nix-instantiate`, `nix-build`, `nix develop`.
*   **Nix Formatters & Linters:** `nixpkgs-fmt`, `nix-linter` (if available/configured).
*   **Git & Submodule Checks:** `git status`, `git diff`, `git submodule status`.
*   **Custom Scripts/Tests:** Leverage shell scripts for automation and implement unit tests for critical Nix functions.

### Test Categories & Procedures:

1.  **Syntax and Formatting Checks:**
    *   **Procedure:** Run `nixpkgs-fmt --check .` across the entire project. Integrate into pre-commit hooks.
    *   **Expected Outcome:** No formatting errors; all files conform to `nixpkgs-fmt` standards.

2.  **Flake Evaluation & Instantiation:**
    *   **Procedure:**
        *   For the root flake: `nix flake check`
        *   For submodule flakes: Navigate to each submodule directory and run `nix flake check`.
        *   For individual Nix expressions: `nix eval --raw -f <file.nix>` or `nix-instantiate <file.nix>`.
    *   **Expected Outcome:** All flakes evaluate and instantiate without errors. Outputs are as expected.

3.  **Derivation Buildability:**
    *   **Procedure:**
        *   For packages defined in flakes: `nix build .#<package-name>`
        *   For specific derivations: `nix-build <derivation-path>`
        *   Test all default packages and applications defined in `flake.nix` outputs.
    *   **Expected Outcome:** All specified derivations build successfully without runtime errors.

4.  **Development Environment (`devShell`) Verification:**
    *   **Procedure:** Run `nix develop` (or `nix-shell`) in directories with `flake.nix` or `shell.nix` to ensure the environment loads correctly and provides the expected tools.
    *   **Expected Outcome:** The `devShell` activates without errors, and essential tools are available on the PATH.

5.  **Dependency Management & Purity:**
    *   **Procedure:**
        *   Review `flake.lock` files for consistency and to ensure all inputs are locked to specific revisions (especially for GitHub URLs).
        *   Manually inspect Nix files for impure constructs (e.g., `builtins.fetchTarball` without a `sha256`, direct access to `/etc`).
    *   **Expected Outcome:** `flake.lock` files are up-to-date. No unintended impure builds.

6.  **Cross-System Compatibility (if applicable):**
    *   **Procedure:** If the project targets multiple systems (e.g., `aarch64-linux`, `x86_64-linux`), run `nix flake check --system <target-system>` and `nix build .#<package-name> --system <target-system>` for each target.
    *   **Expected Outcome:** Builds and evaluations succeed on all supported systems.

7.  **Documentation & Readability:**
    *   **Procedure:** Manual review of Nix files for clear comments, meaningful variable names, and adherence to project-specific coding conventions.
    *   **Expected Outcome:** Nix files are understandable and maintainable.

### Reporting & Metrics:
*   **Pass/Fail:** Each test category will have a clear pass/fail status.
*   **Error Logs:** Detailed logs of any `nix` command failures, linter warnings, or build errors.
*   **Coverage (Optional):** Track the percentage of Nix files covered by automated checks.

### Frequency:
*   **Pre-commit Hook:** Formatting and basic syntax checks.
*   **CI/CD Pipeline:** Full suite of checks on every push to a feature branch and `main`.
*   **Local Development:** Developers are encouraged to run `nix flake check` and `nix build` frequently.

## Impact
*   Significantly improved reliability and reproducibility of the Nix-based build system.
*   Reduced debugging time due to early detection of Nix-related issues.
*   Enhanced code quality and maintainability of Nix expressions.
*   Increased confidence in the correctness of project dependencies and environments.

## Related CRQs
*   CRQ-016: Flake Refactor and Submodule Consistency
*   CRQ-022: Quality Doctrine
*   CRQ-044: Recurring Nix Flake Syntax Error Pattern
