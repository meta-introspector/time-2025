#!/usr/bin/env bash

MAIN_REPO_DIR=$(pwd)

# Desired branch name to check for
TARGET_BRANCH="feature/lattice-30030-homedir"

echo "--- Submodule Information Report ---"

git submodule status | while read -r line ; do
    # Extract submodule path
    submodule_path=$(echo "$line" | awk '{print $2}')

    echo "\nSubmodule: $submodule_path"
    echo "----------------------------------------"

    if [ -d "$submodule_path" ]; then
        cd "$submodule_path" || continue

        # Get remote URL
        remote_url=$(git remote get-url origin 2>/dev/null || git remote get-url upstream 2>/dev/null)
        echo "Remote URL: ${remote_url:-N/A}"

        # Get current branch
        current_branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
        echo "Current Branch: ${current_branch:-N/A}"

        # Check for target branch existence and create/push if it doesn't exist
        if git branch -a | grep -q "$TARGET_BRANCH"; then
            echo "Target Branch ($TARGET_BRANCH): Exists"
        else
            echo "Target Branch ($TARGET_BRANCH): Does NOT exist. Creating and pushing..."
            git checkout -b "$TARGET_BRANCH"
            git push -u origin "$TARGET_BRANCH"
            echo "Branch $TARGET_BRANCH created and pushed."
        fi

        # Report git status
        echo "\nGit Status:"
        git status

        cd "$MAIN_REPO_DIR" || exit 1
    else
        echo "Error: Submodule directory not found at $submodule_path"
    fi
done

echo "\n--- Report Complete ---"
