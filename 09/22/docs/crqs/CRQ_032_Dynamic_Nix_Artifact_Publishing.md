# CRQ-032: Dynamic Nix Artifact Publishing

*   **Status:** Active
*   **Author:** Gemini
*   **Date:** 2025-09-23

## 1. Problem Statement

The project currently relies on a hard-coded, script-based approach to publishing Nix artifacts. For each artifact, a dedicated shell script exists that calls a generic publishing script with hard-coded parameters (flake attribute and repository URL). This approach is not scalable, is prone to errors, and creates unnecessary boilerplate code.

## 2. Proposed Solution

Transition to a dynamic and centralized approach for publishing Nix artifacts. This involves eliminating the individual, hard-coded scripts and instead relying on a single, generic script that accepts the flake attribute and target repository as command-line arguments. This will streamline the process of publishing artifacts, reduce code duplication, and improve maintainability.

## 3. Scope

*   **In Scope:**
    *   The creation of this CRQ to document the new process.
    *   The deprecation and removal of the old, hard-coded publishing scripts.
    *   The adoption of the new dynamic publishing workflow for all new artifacts.

*   **Out of Scope:**
    *   Changes to the underlying Nix infrastructure.
    *   Modifications to the generic publishing script (`scripts/publish_nix_artifact_to_git.sh`) itself, unless necessary to support this CRQ.

## 4. Implementation Details

The new workflow is centered around the `scripts/publish_nix_artifact_to_git.sh` script. This script takes two arguments:

1.  **Flake Attribute Path:** The path to the Nix flake attribute to be built and published (e.g., `./nix-llm-context#packages.aarch64-linux.monsterGroupLlmContext`).
2.  **Repository URL:** The URL of the Git repository to which the artifact will be published (e.g., `https://github.com/meta-introspector/crq-binstore.git`).

### Example Usage:

```bash
./scripts/publish_nix_artifact_to_git.sh \
  "./nix-llm-context#packages.aarch64-linux.monsterGroupLlmContext" \
  "https://github.com/meta-introspector/crq-binstore.git"
```

This command will:

1.  Build the specified Nix flake attribute.
2.  Export the resulting artifact to a `.nar` file.
3.  Commit and push the `.nar` file to the specified Git repository.

## 5. Rollback Plan

The old, hard-coded scripts can be restored from Git history if the new dynamic approach proves to be problematic. However, given the simplicity and improved maintainability of the new workflow, a rollback is considered highly unlikely.
