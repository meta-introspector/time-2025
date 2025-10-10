# SOP: Nix Path Purity and External Dependency Referencing

## 1. Purpose

This Standard Operating Procedure (SOP) outlines the policy for referencing external dependencies, particularly Git submodules, within Nix flakes. It aims to enforce path purity, enhance reproducibility, and ensure adherence to the project's external dependency integration policy.

## 2. Scope

This SOP applies to all `.nix` files, `flake.nix` configurations, and any other Nix-related code within the project that references external repositories or submodules.

## 3. Policy

All external dependencies, including Git submodules and submodules of submodules, **must be referenced exclusively by their `github:meta-introspector` URLs**. Direct local path references (e.g., `path:./some/path` or `self + "/some/path"`) to submodules are strictly prohibited for general integration.

## 4. Problem Statement: Local Path References to Submodules

Referencing submodules via local paths (e.g., `path:./09/26/jobs/vendor/nix-task`) or using `self + "/some/path"` for submodule content introduces several issues:

*   **Reproducibility Challenges:** Local path references can break when the project is built in different environments or when the submodule's content is not correctly synchronized with the superproject's Gitlink.
*   **Nix Store Resolution Issues:** Nix's content-addressable store relies on stable, globally resolvable URLs. Local paths to submodules can lead to ambiguous or unresolvable paths within the Nix store, especially during `nix flake update` or `nix build` operations.
*   **Violation of External Dependency Policy:** The project's policy mandates `github:meta-introspector` URLs for all external dependencies to ensure a centralized, controlled, and auditable source for all components.

## 5. Correct Referencing: `github:meta-introspector` URLs

All references to submodules, whether direct or indirect (submodules of submodules), must use the following format:

`github:meta-introspector/<repo_name>?ref=<branch_name>&dir=<path_within_repo>`

Where:
*   `<repo_name>`: The name of the GitHub repository (e.g., `nix-task`, `time-2025`).
*   `<branch_name>`: The specific branch or tag (e.g., `feature/lattice-30030-homedir`, `v1.0.0`).
*   `<path_within_repo>`: The path to the flake or content within that repository (e.g., `nix/base-job`, `09/22/crq-binstore`).

**Example of Correct Referencing:**

```nix
inputs = {
  # Correct: References the nix-task flake via its GitHub URL
  nixTask = {
    url = "github:meta-introspector/nix-task?ref=feature/lattice-30030-homedir";
  };

  # Correct: References a specific directory within the nix-task repository
  baseJob = {
    url = "github:meta-introspector/nix-task?dir=nix/base-job&ref=feature/lattice-30030-homedir";
  };
};
```

**Example of Incorrect Referencing (Prohibited):**

```nix
inputs = {
  # Incorrect: Local path reference to a submodule
  nnixTask = {
    url = "path:./09/26/jobs/vendor/nix-task";
    flake = true;
  };

  # Incorrect: Using self + "/..." for submodule content
  somePath = self + "/09/22/crq-binstore/some-file.nix";
};
```

## 6. Remediation Steps

1.  **Identify Local Path References:** Use `grep -rE "path:|self \+ "/" . --include="*.nix"` to find all local path references.
2.  **Determine Corresponding GitHub URL:** For each identified local path, determine the correct `github:meta-introspector` URL, including the repository name, branch, and path within the repository.
3.  **Update `flake.nix`:** Replace the local path reference with the corresponding `github:` URL.
4.  **Run `nix flake update`:** After updating `flake.nix`, run `nix flake update` to regenerate `flake.lock` with the correct GitHub references.
5.  **Verify:** Run `nix flake check` and `nix build` to ensure all flakes resolve and build correctly.

## 7. Benefits

Adhering to this policy ensures:
*   **Enhanced Reproducibility:** All dependencies are sourced from stable, globally resolvable GitHub URLs.
*   **Improved Maintainability:** Centralized referencing simplifies dependency management and updates.
*   **Policy Compliance:** Ensures consistency with the project's external dependency integration guidelines.
*   **Clearer Dependency Graph:** Makes the project's dependency graph more transparent and easier to understand.
