#!/usr/bin/env bash

source "$(dirname "$0")/lib_git_submodule.sh"

set -e

# TAG_NAME is skipped for now as per user request
CRQ_NUMBER="016"
COMMIT_DESCRIPTION="Standardize flake.nix from template"
BRANCH_NAME="feature/CRQ-016-nixify-workflow" # Ensure this matches the current branch

if [ -n "$1" ]; then
    SUBMODULE_PATHS="$1"
else
    # Discover submodules by finding flake.nix files in vendor/nix subdirectories
    SUBMODULE_PATHS=$(find vendor/nix -mindepth 2 -maxdepth 2 -type f -name "flake.nix" -print0 | xargs -0 -n1 dirname)
fi

if [ -z "$SUBMODULE_PATHS" ]; then
    echo "No meta-introspector repositories found or provided."
    exit 1
fi

echo "Found the following submodules to process: $SUBMODULE_PATHS"

for submodule_path in $SUBMODULE_PATHS; do
    repo=$(basename "$submodule_path")
    echo "--- Processing $repo at $submodule_path ---"

    # Ensure the correct branch is checked out
    (
        cd "$submodule_path"
        if git rev-parse --verify "$BRANCH_NAME" &>/dev/null; then
            echo "Branch $BRANCH_NAME already exists. Checking it out."
            git checkout "$BRANCH_NAME"
        else
            echo "Branch $BRANCH_NAME does not exist. Creating and checking it out."
            git checkout -b "$BRANCH_NAME"
        fi
    )

    # Commit the changes using the existing script
    ./scripts/commit_crq_submodule.sh "$submodule_path" "$CRQ_NUMBER" "$COMMIT_DESCRIPTION"

    # Now, push (tagging is skipped as per user request)
    (
        cd "$submodule_path"
        echo "Pushing changes..."

        ensure_meta_introspector_remote_and_fork "$repo"

        git push origin HEAD || { git pull --rebase origin HEAD && git push origin HEAD; }
        # git tag -f "$TAG_NAME" # Tagging skipped
        # git push origin "$TAG_NAME" --force # Tagging skipped
    )
    echo "--- Finished $repo ---"
    echo
done

echo "All submodules have been committed and pushed."