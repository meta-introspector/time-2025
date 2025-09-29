# Change Request (CRQ): Mass Adoption of Nix-based Pre-commit Hooks

**CRQ ID:** CRQ-XXXX (To be assigned)
**Date:** 2025-09-27
**Author:** Gemini Agent

## 1. Executive Summary

This Change Request proposes the mass adoption of a standardized Nix-based pre-commit hook system across all relevant project repositories. This system leverages the `pre-commit` framework, integrated with Nix flakes, to enforce consistent code formatting, static analysis, and conventional commit messages for Nix, Shell, and other supported file types. Mass adoption will significantly enhance code quality, reduce technical debt, streamline code reviews, and improve overall development efficiency.

## 2. Problem Statement

Currently, code quality and consistency checks are often performed manually or inconsistently across different developer environments and project repositories. This leads to:

*   **Inconsistent Code Style:** Variations in formatting and coding practices, especially for Nix and Shell scripts.
*   **Increased Technical Debt:** Introduction of easily preventable issues into the codebase.
*   **Inefficient Code Reviews:** Reviewers spend valuable time identifying and correcting basic formatting and linting errors.
*   **Delayed Feedback:** Issues are often caught late in the development cycle, increasing the cost of remediation.
*   **Lack of Standardization:** No unified approach to ensuring code quality at the commit level.

## 3. Proposed Solution

Implement a standardized Nix-based pre-commit hook system using the `pre-commit` framework. This system is defined within a `flake.nix` and a `.pre-commit-config.yaml` file, ensuring that all necessary tools (e.g., `nixpkgs-fmt`, `statix`, `shellcheck`, `commitlint`) are consistently available and applied across all developer environments.

**Key Components:**

*   **`flake.nix`:** Defines a development shell that provides the `pre-commit` tool and all necessary linters/formatters (`nixpkgs-fmt`, `statix`, `shellcheck`, `commitlint`).
*   **`.pre-commit-config.yaml`:** Configures the specific hooks to run, their execution order, and the file types they apply to.
*   **`setup_precommit_hooks.sh`:** A simple script to automate the one-time installation of Git hooks for developers.
*   **`commit.sh`:** A wrapper script to ensure `git commit` is always run within the Nix development environment, guaranteeing hook execution.

## 4. Benefits

Mass adoption of this system will yield the following benefits:

*   **Enhanced Code Quality:** Automated checks catch issues early, leading to cleaner, more reliable code.
*   **Improved Code Consistency:** Enforces uniform formatting and coding standards across the entire codebase.
*   **Streamlined Code Reviews:** Reviewers can focus on logic and architecture, not superficial errors.
*   **Reduced Technical Debt:** Prevents common mistakes from entering the main branch.
*   **Faster Feedback Loop:** Developers receive immediate feedback on issues, reducing rework.
*   **Standardized Development Environment:** Ensures all developers use the same versions of linting and formatting tools.
*   **"Bott" Principles Alignment:** Directly supports "Pattern Discernment" (bott 5), "Verification and Testing" (bott 10), "Error Analysis and Transformation" (bott 9), and "Integration and Session Correlation" (bott 11) by embedding quality checks and structured practices into the development workflow.

## 5. Impact Analysis

*   **Developers:**
    *   **Positive:** Will receive immediate feedback on code quality, reducing manual corrections and improving efficiency. Ensures consistency without manual effort.
    *   **Negative:** Requires a one-time setup (`./setup_precommit_hooks.sh`) and adherence to defined standards. Initial learning curve for new hooks.
*   **CI/CD Pipelines:**
    *   **Positive:** Can easily integrate `pre-commit` checks to ensure only high-quality code reaches the main branch, reducing build failures and deployment issues.
    *   **Negative:** Requires updating CI/CD configurations to run `pre-commit` checks.
*   **Codebase:**
    *   **Positive:** Significant improvement in overall code quality, readability, and maintainability.
*   **Project Management:**
    *   **Positive:** Reduced risk of quality-related delays, improved project predictability.

## 6. Rollout Plan

1.  **Pilot Program (Current Project):** The system has been successfully implemented and tested in the current project (`streamofrandom/2025/09/27`).
2.  **Documentation & Training:** Develop comprehensive documentation (SOPs, FAQs) and conduct brief training sessions for development teams.
3.  **Phased Rollout:**
    *   **Phase 1 (Voluntary Adoption):** Encourage teams to voluntarily adopt the pre-commit system in their repositories.
    *   **Phase 2 (Mandatory for New Repositories):** Make the pre-commit system mandatory for all new project repositories.
    *   **Phase 3 (Mandatory for Existing Repositories):** Gradually roll out mandatory adoption for existing repositories, prioritizing critical or frequently modified ones.
4.  **Support & Feedback:** Establish a channel for support and feedback during the rollout phases.

## 7. Success Metrics

*   Reduction in linting/formatting issues reported in code reviews.
*   Decrease in CI/CD failures related to code style or basic errors.
*   Positive feedback from development teams regarding code quality and consistency.
*   Increased adherence to conventional commit message standards.

## 8. Approval

[ ] Approved
[ ] Approved with modifications (see comments)
[ ] Rejected

**Approver:** _________________________
**Date:** _________________________
