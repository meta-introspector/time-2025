#!/usr/bin/env bash

set -e

source "$(dirname "$0")/lib_git_submodule.sh"

# Check if a submodule path is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <submodule_path>"
    exit 1
fi

SUBMODULE_PATH="$1"

# Get the current branch name of the main repository
MAIN_REPO_BRANCH=$(git rev-parse --abbrev-ref HEAD)

if [ -z "$MAIN_REPO_BRANCH" ]; then
    echo "Could not determine the current branch of the main repository."
    exit 1
fi

TAG_NAME="CRQ-016-${MAIN_REPO_BRANCH}"

echo "Attempting to tag submodule '$SUBMODULE_PATH' with tag '$TAG_NAME'"

if [ -d "$SUBMODULE_PATH" ]; then
    echo "--- Processing submodule at $SUBMODULE_PATH ---"
    (
        cd "$SUBMODULE_PATH"
        echo "Current directory: $(pwd)"

        echo "Adding tag $TAG_NAME"
        git_tag_force "$TAG_NAME"

        echo "Pushing tag $TAG_NAME to origin"
        git_push_tag_force "$TAG_NAME"
    )
    echo "--- Finished processing $SUBMODULE_PATH ---"
    echo
else
    echo "Error: Submodule path '$SUBMODULE_PATH' not found."
    exit 1
fi

echo "Tagging process completed."
