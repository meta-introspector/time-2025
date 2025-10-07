# SOP: GitHub Meta-Introspector Paths Policy

## 1. Purpose

This Standard Operating Procedure (SOP) establishes a mandatory policy for referencing external repositories and Nix flake inputs within the project. The purpose is to standardize all such references to originate from the `github:meta-introspector` organization, ensuring consistency, control, and adherence to project-specific vendoring and introspection practices.

## 2. Scope

This policy applies to all developers, contributors, and automated systems working within the project. It covers:
*   All Nix flake inputs (e.g., `nixpkgs`, `flake-utils`, custom libraries).
*   Any direct references to GitHub repositories in scripts, configuration files, or documentation where a `github:` URL is used.

## 3. Policy Details

### 3.1 Mandatory `github:meta-introspector` Prefix

All references to GitHub repositories MUST use the `github:meta-introspector/` prefix. This means that instead of referencing upstream repositories directly (e.g., `github:NixOS/nixpkgs`), the project MUST use a vendored fork within the `meta-introspector` organization (e.g., `github:meta-introspector/nixpkgs`).

### 3.2 Branch-Specific References

References to repositories within `github:meta-introspector` MUST specify a branch or a specific commit hash, preferably a branch that aligns with project-specific features or fixes (e.g., `ref=feature/CRQ-016-nixify`). Direct use of `master` or `main` branches without a specific `ref` is discouraged unless explicitly approved for stable, unchanging dependencies.

### 3.3 Vendoring and Forking

Any external dependency that is not already available under `github:meta-introspector` MUST be forked into the `meta-introspector` organization before being referenced in the project. This ensures that the project maintains control over its dependencies and can apply necessary patches or modifications without relying on upstream changes.

## 4. Compliance

Failure to adhere to this policy will result in:
*   Pre-commit hook failures.
*   Nix build failures.
*   Code review rejections.

Developers are responsible for ensuring their changes comply with this SOP before submitting pull requests.

## 5. Related Documents

*   `GEMINI.md` (Operational Guidelines)
*   `docs/crqs/CRQ-016_Nixification_Workflow.md` (if applicable)
