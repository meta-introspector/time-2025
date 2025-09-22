#!/usr/bin/env bash

set -euo pipefail

PROJECT_ROOT="$(dirname "$(dirname "$(realpath "$0")")")"
source "${PROJECT_ROOT}/lib/lib_github_fork.sh"

# This script vendorizes a GitHub repository as a Git submodule
# and checks out a specific branch.

DRY_RUN=false

# Parse arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run)
      DRY_RUN=true
      shift # past argument
      ;;
    -*)
      echo "Unknown option $1"
      exit 1
      ;;
    *)
      break # stop processing options
      ;;
  esac
done

ORIGINAL_REPO_URL="$1"
SUBMODULE_PATH="$2"
FORK_NAME="$3" # New argument for the forked repository name
TARGET_BRANCH="${4:-feature/CRQ-016-nixify-workflow}" # New argument for target branch, with default
META_INTROSPECTOR_ORG="meta-introspector"

if [ -z "$ORIGINAL_REPO_URL" ] || [ -z "$SUBMODULE_PATH" ]; then
    echo "Usage: $0 [--dry-run] <original_repo_url> <submodule_path> [fork_name] [target_branch]"
    echo "Example: $0 --dry-run github:numtide/flake-utils vendor/nix/flake-utils flake-utils-fork feature/CRQ-016-nixify-workflow"
    exit 1
fi

if [ "$DRY_RUN" = "true" ]; then
  echo "Running in DRY-RUN mode. No changes will be made."
fi

echo "Vendorizing $ORIGINAL_REPO_URL to $SUBMODULE_PATH"

if [[ "$ORIGINAL_REPO_URL" =~ ^github:([^/]+)/([^/]+)$ ]]; then
    HTTPS_REPO_URL="https://github.com/${BASH_REMATCH[1]}/${BASH_REMATCH[2]}.git"
    ORIGINAL_REPO_BASENAME="${BASH_REMATCH[2]}"
else
    HTTPS_REPO_URL="$ORIGINAL_REPO_URL"
    ORIGINAL_REPO_BASENAME=$(basename "$ORIGINAL_REPO_URL" .git)
fi

# Determine the name of the forked repository
FORKED_REPO_NAME="${FORK_NAME:-$ORIGINAL_REPO_BASENAME}"

# Check if submodule already exists
if [ -d "$SUBMODULE_PATH" ]; then
    echo "Submodule $SUBMODULE_PATH already exists. Updating it."
    if [ "$DRY_RUN" = "false" ]; then
        (cd "$SUBMODULE_PATH" && git pull origin "$TARGET_BRANCH") || \
        (cd "$SUBMODULE_PATH" && git fetch origin && git checkout "$TARGET_BRANCH" && git pull origin "$TARGET_BRANCH")
    else
        echo "DRY-RUN: Would update submodule $SUBMODULE_PATH."
    fi
else
    echo "Adding submodule $SUBMODULE_PATH from $HTTPS_REPO_URL"
    if [ "$DRY_RUN" = "false" ]; then
        git submodule add "$HTTPS_REPO_URL" "$SUBMODULE_PATH"
    else
        echo "DRY-RUN: Would add submodule $SUBMODULE_PATH from $HTTPS_REPO_URL."
    fi
fi

mkdir -p "$SUBMODULE_PATH"

# Navigate into the submodule
(
    cd "$SUBMODULE_PATH" || exit 1

    # Ensure the meta-introspector remote exists and is correct
    META_INTROSPECTOR_REMOTE_URL="https://github.com/${META_INTROSPECTOR_ORG}/${FORKED_REPO_NAME}.git"
    if git remote | grep -q "^${META_INTROSPECTOR_ORG}"$; then
        echo "Remote '${META_INTROSPECTOR_ORG}' already exists. Setting URL."
        if [ "$DRY_RUN" = "false" ]; then
            git remote set-url "${META_INTROSPECTOR_ORG}" "$META_INTROSPECTOR_REMOTE_URL"
        else
            echo "DRY-RUN: Would set remote URL for '${META_INTROSPECTOR_ORG}' to $META_INTROSPECTOR_REMOTE_URL."
        fi
    else
        echo "Adding remote '${META_INTROSPECTOR_ORG}' with URL $META_INTROSPECTOR_REMOTE_URL"
        if [ "$DRY_RUN" = "false" ]; then
            git remote add "${META_INTROSPECTOR_ORG}" "$META_INTROSPECTOR_REMOTE_URL"
        else
            echo "DRY-RUN: Would add remote '${META_INTROSPECTOR_ORG}' with URL $META_INTROSPECTOR_REMOTE_URL."
        fi
    fi

    # Attempt to fork the repository if it doesn't exist in the meta-introspector organization
    FORK_CREATED=false
    if ! gh repo view "${META_INTROSPECTOR_ORG}/${FORKED_REPO_NAME}" &>/dev/null; then
        echo "Forking ${ORIGINAL_REPO_URL} to ${META_INTROSPECTOR_ORG}/${FORKED_REPO_NAME}..."
        if [ "$DRY_RUN" = "false" ]; then
            if ! lib_github_fork_repo "${ORIGINAL_REPO_URL}" "${META_INTROSPECTOR_ORG}" "${FORKED_REPO_NAME}"; then
                echo "Error: Failed to fork repository. Please ensure gh CLI is authenticated and has permissions."
                exit 1
            fi
            FORK_CREATED=true
        else
            echo "DRY-RUN: Would fork ${ORIGINAL_REPO_URL} to ${META_INTROSPECTOR_ORG}/${FORKED_REPO_NAME}."
        fi
    fi

    # If a new fork was created, ensure the target branch exists and is pushed to the meta-introspector remote
    if [ "$FORK_CREATED" = "true" ]; then
        echo "Ensuring target branch '$TARGET_BRANCH' exists on '${META_INTROSPECTOR_ORG}' remote..."
        if [ "$DRY_RUN" = "false" ]; then
            # Fetch from original to get the branch if it exists there
            git fetch origin "$TARGET_BRANCH" || true # Allow failure if branch doesn't exist in original

            if git rev-parse --verify --quiet "$TARGET_BRANCH" >/dev/null; then
                # If target branch exists locally (from original), push it to the new fork
                echo "Pushing existing branch '$TARGET_BRANCH' to new fork '${META_INTROSPECTOR_ORG}'."
                git push "${META_INTROSPECTOR_ORG}" "$TARGET_BRANCH"
            else
                # If target branch doesn't exist locally, create it from main/master and push
                echo "Creating and pushing branch '$TARGET_BRANCH' from default branch to new fork '${META_INTROSPECTOR_ORG}'."
                if git rev-parse --verify --quiet "origin/main" >/dev/null; then
                    git checkout -b "$TARGET_BRANCH" origin/main
                elif git rev-parse --verify --quiet "origin/master" >/dev/null; then
                    git checkout -b "$TARGET_BRANCH" origin/master
                else
                    echo "Warning: Neither 'main' nor 'master' branch found in original remote. Cannot create target branch from default."
                    # Fallback: create an empty branch and push (might not be desired, but avoids script failure)
                    git checkout --orphan "$TARGET_BRANCH"
                    git rm -rf .
                    git commit --allow-empty -m "feat(${FORKED_REPO_NAME}): Initial empty branch for CRQ-016-nixify"
                fi
                git push -u "${META_INTROSPECTOR_ORG}" "$TARGET_BRANCH"
            fi
            git checkout -
        else
            echo "DRY-RUN: Would ensure target branch '$TARGET_BRANCH' exists and is pushed to new fork '${META_INTROSPECTOR_ORG}'."
        fi
    fi

    # Fetch the target branch from the meta-introspector remote
    echo "Fetching branch '$TARGET_BRANCH' from '${META_INTROSPECTOR_ORG}'"
    if [ "$DRY_RUN" = "false" ]; then
        git fetch "${META_INTROSPECTOR_ORG}" "$TARGET_BRANCH"
    else
        echo "DRY-RUN: Would fetch branch '$TARGET_BRANCH' from '${META_INTROSPECTOR_ORG}'."
    fi

    # Fetch the default branch (assuming 'main' or 'master')
    if [ "$DRY_RUN" = "false" ]; then
        git fetch "${META_INTROSPECTOR_ORG}" main || git fetch "${META_INTROSPECTOR_ORG}" master
    else
        echo "DRY-RUN: Would fetch default branch (main/master) from '${META_INTROSPECTOR_ORG}'."
    fi

    # Check out or create the target branch
    if git rev-parse --verify --quiet "$TARGET_BRANCH" >/dev/null; then
        echo "Branch '$TARGET_BRANCH' already exists locally. Checking it out."
        if [ "$DRY_RUN" = "false" ]; then
            git checkout "$TARGET_BRANCH"
        else
            echo "DRY-RUN: Would checkout branch '$TARGET_BRANCH'."
        fi
    else
        echo "Branch '$TARGET_BRANCH' does not exist locally. Creating it from default branch."
        # Try to create from 'main', fallback to 'master'
        if [ "$DRY_RUN" = "false" ]; then
            if git rev-parse --verify --quiet "${META_INTROSPECTOR_ORG}/main" >/dev/null; then
                git checkout -b "$TARGET_BRANCH" "${META_INTROSPECTOR_ORG}/main"
            elif git rev-parse --verify --quiet "${META_INTROSPECTOR_ORG}/master" >/dev/null; then
                git checkout -b "$TARGET_BRANCH" "${META_INTROSPECTOR_ORG}/master"
            else
                echo "Error: Neither 'main' nor 'master' branch found in '${META_INTROSPECTOR_ORG}' remote. Cannot create branch."
                exit 1
            fi
        else
            echo "DRY-RUN: Would create and checkout branch '$TARGET_BRANCH' from default branch."
        fi
    fi

    # Push to the meta-introspector remote
    echo "Pushing branch '$TARGET_BRANCH' to '${META_INTROSPECTOR_ORG}'"
    if [ "$DRY_RUN" = "false" ]; then
        git push -u "${META_INTROSPECTOR_ORG}" "$TARGET_BRANCH"
    else
        echo "DRY-RUN: Would push branch '$TARGET_BRANCH' to '${META_INTROSPECTOR_ORG}'."
    fi

)

echo "Finished vendorizing and forking $SUBMODULE_PATH."

