# SOP: Publishing Monster Group NAR File

## 1. Purpose

This Standard Operating Procedure (SOP) describes the process of publishing the pre-defined Nix Archive (NAR) file for the "Monster Group" LLM context to a designated Git repository. This script simplifies the process by encapsulating the specific flake attribute path and repository URL.

## 2. Scope

This SOP applies to anyone needing to publish or re-publish the Monster Group LLM context NAR file.

## 3. Prerequisites

-   A working Nix environment with flakes enabled.
-   Access to the `publish_nix_artifact_to_git.sh` script.
-   Network connectivity to the target Git repository.

## 4. Procedure

The `scripts/publish_monster_group_nar.sh` script acts as a convenience wrapper for `publish_nix_artifact_to_git.sh`.

### 4.1. Script Location

The script is located at: `/data/data/com.termux.nix/files/home/pick-up-nix2/source/github/meta-introspector/streamofrandom/2025/09/22/scripts/publish_monster_group_nar.sh`

### 4.2. Usage

To run the script, execute it from the project root:

```bash
/data/data/com.termux.nix/files/home/pick-up-nix2/source/github/meta-introspector/streamofrandom/2025/09/22/scripts/publish_monster_group_nar.sh
```

### 4.3. Script Functionality

This script performs the following:

1.  **Defines Parameters**: It sets the `FLAKE_ATTR_PATH` to `./nix-llm-context#packages.aarch64-linux.monsterGroupLlmContext` and `REPO_URL` to `https://github.com/meta-introspector/crq-binstore.git`.
2.  **Calls Publishing Script**: It then calls `scripts/publish_nix_artifact_to_git.sh` with these hardcoded parameters. The `publish_nix_artifact_to_git.sh` script handles the actual building, NAR export, Git operations (add, commit, push), and error handling.

## 5. Verification

Refer to the verification steps outlined in `SOP_Publish_Nix_Artifact_To_Git.md` to confirm the successful publication of the Monster Group NAR file.

## 6. Related Files

-   `/data/data/com.termux.nix/files/home/pick-up-nix2/source/github/meta-introspector/streamofrandom/2025/09/22/scripts/publish_nix_artifact_to_git.sh`: The core script used for publishing Nix artifacts.
-   The `nix-llm-context` flake.
-   The `crq-binstore` Git repository.
