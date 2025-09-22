#!/usr/bin/env bash

# This script moves a Git submodule from an old path to a new path.
# It performs deinitialization, removal, directory movement, and re-addition.
# This script uses direct Git and file system commands as no existing library
# functions encapsulate this specific workflow.

set -e

OLD_SUBMODULE_PATH="$1"
NEW_SUBMODULE_PATH="$2"
SUBMODULE_URL="$3"

if [ -z "$OLD_SUBMODULE_PATH" ] || [ -z "$NEW_SUBMODULE_PATH" ] || [ -z "$SUBMODULE_URL" ]; then
    echo "Usage: $0 <old_submodule_path> <new_submodule_path> <submodule_url>"
    exit 1
fi

echo "Attempting to move submodule from '$OLD_SUBMODULE_PATH' to '$NEW_SUBMODULE_PATH'"

# 1. Deinitialize the submodule at the old path
echo "Deinitializing submodule: $OLD_SUBMODULE_PATH"
git submodule deinit -f "$OLD_SUBMODULE_PATH"

# 2. Remove the submodule entry from .gitmodules and .git/config
echo "Removing submodule from Git: $OLD_SUBMODULE_PATH"
git rm -f "$OLD_SUBMODULE_PATH"

# 3. Remove the submodule's git directory
# This step is crucial as git rm only removes the working tree and .gitmodules entry
# The actual .git/modules entry needs to be manually removed.
GIT_MODULES_PATH=".git/modules/$OLD_SUBMODULE_PATH"
if [ -d "$GIT_MODULES_PATH" ]; then
    echo "Removing submodule's Git directory: $GIT_MODULES_PATH"
    rm -rf "$GIT_MODULES_PATH"
else
    echo "Submodule's Git directory not found (already removed or never existed): $GIT_MODULES_PATH"
fi

# 4. Move the submodule's working directory (if it still exists)
if [ -d "$OLD_SUBMODULE_PATH" ]; then
    echo "Moving submodule directory from '$OLD_SUBMODULE_PATH' to '$NEW_SUBMODULE_PATH'"
    mkdir -p "$(dirname "$NEW_SUBMODULE_PATH")"
    mv "$OLD_SUBMODULE_PATH" "$NEW_SUBMODULE_PATH"
else
    echo "Submodule working directory not found (already moved or removed): $OLD_SUBMODULE_PATH"
fi

# 5. Add the submodule at the new path with its original URL
echo "Adding submodule at new path: $NEW_SUBMODULE_PATH with URL: $SUBMODULE_URL"
git submodule add "$SUBMODULE_URL" "$NEW_SUBMODULE_PATH"

echo "Submodule move completed successfully."
