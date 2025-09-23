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
NIX_STORE_PATH=$(readlink result)
execute_cmd echo "Nix store path for artifact: $NIX_STORE_PATH"

# 3. Ensure the Git repository is cloned and up-to-date
execute_cmd echo "Ensuring local Git repository '$REPO_DIR_NAME' is ready."
git_ensure_repo_cloned_and_updated "$REPO_URL" "$REPO_DIR_NAME" main

# Change into the repository directory to create the .nar file directly there
execute_cmd pushd "$REPO_DIR_NAME" > /dev/null

# 4. Export the derivation's output to a .nar file directly into the repo
NAR_FILE_NAME=$(basename "$NIX_STORE_PATH").nar
execute_cmd echo "Exporting Nix store path to .nar file: $NAR_FILE_NAME"
execute_cmd echo "NIX_STORE_PATH being exported: $NIX_STORE_PATH"

# Execute nix-store --export and capture its exit code
if execute_cmd bash -c "nix-store --export \"$NIX_STORE_PATH\" > \"$NAR_FILE_NAME\"" ; then
    execute_cmd echo "nix-store --export succeeded."
else
    execute_cmd echo "Error: nix-store --export failed with exit code $?."
    exit 1
fi

# Check if the .nar file was created and its size
if [ ! -f "$NAR_FILE_NAME" ]; then
    execute_cmd echo "Error: .nar file was not created: $NAR_FILE_NAME"
    exit 1
else
    FILE_SIZE=$(stat -c%s "$NAR_FILE_NAME")
    execute_cmd echo "Created .nar file: $NAR_FILE_NAME (Size: $FILE_SIZE bytes)"
    if [ "$FILE_SIZE" -eq 0 ]; then
        execute_cmd echo "Warning: .nar file is empty!"
    fi
fi


# Change back to the original directory
execute_cmd popd > /dev/null


# 6. Add, commit, and push the .nar file
execute_cmd echo "Adding, committing, and pushing '$NAR_FILE_NAME' to '$REPO_URL'."
execute_cmd pushd "$REPO_DIR_NAME" > /dev/null
execute_cmd git add "$NAR_FILE_NAME"
ARTICLE_NAME=$(echo "$FLAKE_ATTR_PATH" | sed -e 's/.*#//' -e 's/Wikidata//')
execute_cmd git commit -m "feat(nar): Add $ARTICLE_NAME $NAR_FILE_NAME"

execute_cmd push_to_origin_branch main
execute_cmd popd > /dev/null

execute_cmd echo "Successfully published Nix artifact '$NAR_FILE_NAME' to '$REPO_URL'."

# Clean up the .nar file from the original directory
execute_cmd echo "Cleaning up local .nar file."
# execute_cmd rm "$NAR_FILE_NAME"
