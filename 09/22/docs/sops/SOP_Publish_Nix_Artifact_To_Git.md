# SOP: Publishing Nix Artifacts to Git Repository

## 1. Purpose

This Standard Operating Procedure (SOP) describes the process of building a specified Nix flake attribute, exporting its output to a `.nar` (Nix Archive) file, and then committing that `.nar` file to a designated Git repository, followed by pushing the changes. This enables the versioning and distribution of Nix build outputs through Git.

## 2. Scope

This SOP applies to developers and maintainers responsible for publishing Nix artifacts, such as LLM context files or other build outputs, to a Git-based binary cache or distribution repository.

## 3. Prerequisites

-   A working Nix environment with flakes enabled.
-   A Git repository (local clone and remote) to publish the artifact to.
-   `curl` installed (implicitly used by `git_ensure_repo_cloned_and_updated` for cloning).
-   `lib_exec.sh` and `lib_git_submodule.sh` libraries sourced.

## 4. Procedure

The `scripts/publish_nix_artifact_to_git.sh` script automates the entire publishing workflow.

### 4.1. Script Location

The script is located at: `/data/data/com.termux.nix/files/home/pick-up-nix2/source/github/meta-introspector/streamofrandom/2025/09/22/scripts/publish_nix_artifact_to_git.sh`

### 4.2. Usage

The script requires two arguments:

1.  `FLAKE_ATTR_PATH`: The path to the Nix flake attribute to build and publish (e.g., `./nix-llm-context#oeisLlmContext`).
2.  `REPO_URL`: The URL of the Git repository where the `.nar` file will be committed and pushed (e.g., `https://github.com/meta-introspector/crq-binstore.git`).

**Example Execution:**

```bash
/data/data/com.termux.nix/files/home/pick-up-nix2/source/github/meta-introspector/streamofrandom/2025/09/22/scripts/publish_nix_artifact_to_git.sh \
  ./nix-llm-context#oeisLlmContext \
  https://github.com/meta-introspector/crq-binstore.git
```

### 4.3. Script Functionality

The script performs the following steps:

1.  **Builds Nix Flake Attribute**: It executes `nix build` on the specified `FLAKE_ATTR_PATH` to generate the artifact.
2.  **Retrieves Nix Store Path**: It reads the `result` symlink created by `nix build` to get the absolute path of the artifact in the Nix store.
3.  **Ensures Git Repository is Ready**: It calls `git_ensure_repo_cloned_and_updated` (from `lib_git_submodule.sh`) to ensure the target Git repository is cloned locally and up-to-date. It checks out the `main` branch.
4.  **Exports to `.nar` File**: It changes into the local Git repository directory and uses `nix-store --export` to convert the Nix store artifact into a `.nar` file. The `.nar` file is named after the Nix store path's basename (e.g., `hash-llm-context-OEIS.nar`).
5.  **Verifies `.nar` File**: It checks if the `.nar` file was successfully created and reports its size.
6.  **Commits and Pushes**: It adds the newly created `.nar` file to the Git repository, commits it with a descriptive message, and then pushes the changes to the `main` branch of the remote repository using `push_to_origin_branch`.
7.  **Cleanup**: (Optional, commented out in script) It can remove the local `.nar` file after pushing.

## 5. Verification

After the script completes, verify the successful publication by:

-   Checking the output of the script for "Successfully published Nix artifact".
-   Navigating to the remote Git repository (`REPO_URL`) to confirm that the `.nar` file has been committed and pushed.
-   Optionally, pulling the changes in another clone of the repository and attempting to use the published artifact.

## 6. Related Files

-   `/data/data/com.termux.nix/files/home/pick-up-nix2/source/github/meta-introspector/streamofrandom/2025/09/22/lib/lib_exec.sh`: Provides the `execute_cmd` function.
-   `/data/data/com.termux.nix/files/home/pick-up-nix2/source/github/meta-introspector/streamofrandom/2025/09/22/lib/lib_git_submodule.sh`: Provides Git utility functions like `git_ensure_repo_cloned_and_updated` and `push_to_origin_branch`.
-   The target Git repository (e.g., `crq-binstore`).
