#!/usr/bin/env bash
#
# Script to publish a Nix artifact (derivation output) to a Git repository.
# This script builds a specified Nix flake attribute, exports its output to a .nar file,
# and then commits that .nar file to a local clone of a Git repository, pushing the changes.

set -euo pipefail

# Source the lib_exec.sh library for execute_cmd
source "/data/data/com.termux.nix/files/home/pick-up-nix2/source/github/meta-introspector/streamofrandom/2025/09/22/lib/lib_exec.sh"

# Source the lib_git_submodule.sh library for git operations
source "/data/data/com.termux.nix/files/home/pick-up-nix2/source/github/meta-introspector/streamofrandom/2025/09/22/lib/lib_git_submodule.sh"

FLAKE_ATTR_PATH="$1" # e.g., "./flake-reconstruction-lattice/#crqNumber"
REPO_URL="$2"        # e.g., "https://github.com/meta-introspector/crq-binstore.git"
REPO_DIR_NAME=$(basename "$REPO_URL" .git) # Local directory name for the Git repo

execute_cmd echo "Publishing Nix artifact from '$FLAKE_ATTR_PATH' to Git repository '$REPO_URL'."

# 1. Build the Nix flake attribute
execute_cmd echo "Building Nix flake attribute: $FLAKE_ATTR_PATH"
execute_cmd nix build "$FLAKE_ATTR_PATH"

# Check if the result symlink exists
if [ ! -L result ]; then
    execute_cmd echo "Error: Nix build did not produce a 'result' symlink."
    exit 1
fi

# 2. Get the resolved path of the result symlink
NIX_STORE_PATH=$(execute_cmd readlink result)
execute_cmd echo "Nix store path for artifact: $NIX_STORE_PATH"

# 3. Export the derivation's output to a .nar file
NAR_FILE_NAME=$(basename "$NIX_STORE_PATH").nar
execute_cmd echo "Exporting Nix store path to .nar file: $NAR_FILE_NAME"
execute_cmd nix-store --export "$NIX_STORE_PATH" > "$NAR_FILE_NAME"

# Check if the .nar file was created
if [ ! -f "$NAR_FILE_NAME" ]; then
    execute_cmd echo "Error: Failed to create .nar file: $NAR_FILE_NAME"
    exit 1
fi

# 4. Ensure the Git repository is cloned and up-to-date
execute_cmd echo "Ensuring local Git repository '$REPO_DIR_NAME' is ready."
git_ensure_repo_cloned_and_updated "$REPO_URL" "$REPO_DIR_NAME" main

# 5. Copy the .nar file into the Git repository
execute_cmd echo "Copying '$NAR_FILE_NAME' into local repository."
execute_cmd cp "../$NAR_FILE_NAME" "$REPO_DIR_NAME/"

# 6. Add, commit, and push the .nar file
execute_cmd echo "Adding, committing, and pushing '$NAR_FILE_NAME' to '$REPO_URL'."
execute_cmd pushd "$REPO_DIR_NAME" > /dev/null
execute_cmd git add "$NAR_FILE_NAME"
execute_cmd git commit -m "feat: Add Nix artifact: $NAR_FILE_NAME (from $FLAKE_ATTR_PATH)"
execute_cmd push_to_origin_branch main
execute_cmd popd > /dev/null

execute_cmd echo "Successfully published Nix artifact '$NAR_FILE_NAME' to '$REPO_URL'."

# Clean up the .nar file from the original directory
execute_cmd echo "Cleaning up local .nar file."
execute_cmd rm "$NAR_FILE_NAME"
