# SOP: Publishing a Generic Knowledge Node NAR

## 1. Purpose

This Standard Operating Procedure (SOP) describes the process of publishing a Nix Archive (NAR) file generated from a "knowledge node" derivation to a designated Git repository (e.g., `crq-binstore`). This SOP provides a generalized approach for sharing structured knowledge defined within Nix flakes.

## 2. Scope

This SOP applies to anyone needing to publish or re-publish a knowledge node NAR file.

## 3. Prerequisites

-   A working Nix environment with flakes enabled.
-   The knowledge node derivation must be defined within a Nix flake and accessible via a flake attribute path (e.g., `.#packages.x86_64-linux.myKnowledgeNode`).
-   Access to the `publish_nix_artifact_to_git.sh` script (assumed to be available in the `scripts/` directory).
-   Network connectivity to the target Git repository (e.g., `https://github.com/meta-introspector/crq-binstore.git`).

## 4. Procedure

The `scripts/publish_knowledge_node_nar.sh` script (to be created) acts as a convenience wrapper for `publish_nix_artifact_to_git.sh`.

### 4.1. Script Location

The script will be located at: `scripts/publish_knowledge_node_nar.sh` (relative to the project root).

### 4.2. Usage

To run the script, execute it from the project root, providing the flake attribute path of the knowledge node and the target repository URL:

```bash
scripts/publish_knowledge_node_nar.sh <FLAKE_ATTR_PATH> <REPO_URL>
# Example: scripts/publish_knowledge_node_nar.sh .#packages.aarch64-linux.knowledge-article-monster-group https://github.com/meta-introspector/crq-binstore.git
```

### 4.3. Script Functionality

This script performs the following:

1.  **Receives Parameters**: It takes `FLAKE_ATTR_PATH` and `REPO_URL` as arguments.
2.  **Calls Publishing Script**: It then calls `scripts/publish_nix_artifact_to_git.sh` with these parameters. The `publish_nix_artifact_to_git.sh` script is responsible for:
    *   Building the specified Nix derivation.
    *   Exporting the build result as a NAR file.
    *   Handling Git operations (cloning, adding the NAR, committing, pushing) to the specified `REPO_URL`).
    *   Ensuring proper error handling.

## 5. Verification

Refer to the verification steps outlined in `SOP_Publish_Nix_Artifact_To_Git.md` (or similar core publishing SOP) to confirm the successful publication of the knowledge node NAR file. Additionally, verify the NAR file appears in the `crq-binstore` repository.

## 6. Related Files

-   `scripts/publish_nix_artifact_to_git.sh`: The core script used for publishing Nix artifacts.
-   The Nix flake defining the knowledge node (e.g., `flake.nix` and `mypackage.nix`).
-   The `crq-binstore` Git repository.
