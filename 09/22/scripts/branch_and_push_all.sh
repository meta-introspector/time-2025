#!/usr/bin/env bash

source "$(dirname "$0")"/lib_git_submodule.sh
source "$(dirname "$0")"/lib_github_parsing.sh

set -e

# --- Configuration ---
BRANCH_NAME="feature/CRQ-016-nixify"
CRQ_NUMBER="016"
COMMIT_DESCRIPTION="Standardize flake.nix from template"
TEMPLATE_FILE="scripts/flake.template"

# --- gh check ---
if ! command -v gh &> /dev/null; then
    echo "GitHub CLI (gh) is not installed." >&2
    exit 1
fi

# --- Template check ---
if [ ! -f "$TEMPLATE_FILE" ]; then
    echo "Error: Template file not found at $TEMPLATE_FILE" >&2
    exit 1
fi
FLAKE_TEMPLATE=$(cat "$TEMPLATE_FILE")

# --- Get Submodules ---
REPOS=$(grep "github:meta-introspector" flake.nix | while read -r line; do get_repo_name_from_github_flake_input "$line"; done | sort -u)
if [ -z "$REPOS" ]; then
    echo "No meta-introspector repositories found in flake.nix" >&2
    exit 1
fi

echo "Found the following repositories to process: $REPOS"

# --- Main Loop ---
for repo in $REPOS; do
    submodule_path="vendor/nix/$repo"
    echo "--- Processing $repo at $submodule_path ---"

    if [ ! -d "$submodule_path" ]; then
        echo "Warning: Submodule path not found at $submodule_path. Skipping."
        continue
    fi

    # --- 1. Nixify ---
    FLAKE_FILE="$submodule_path/flake.nix"
    if [ -f "$FLAKE_FILE" ]; then
        echo "Backing up existing flake.nix to $FLAKE_FILE.bak"
        mv "$FLAKE_FILE" "$FLAKE_FILE.bak"
    fi
    echo "Creating new flake.nix from template."
    echo "$FLAKE_TEMPLATE" > "$FLAKE_FILE"

    # --- 2. Git Operations ---
    (
        cd "$submodule_path"

        ensure_branch_exists_and_checkout "$BRANCH_NAME"

        # --- Commit ---
        echo "Staging and committing flake.nix"
        git add flake.nix
        COMMIT_MESSAGE="feat(flake): CRQ-${CRQ_NUMBER} - ${COMMIT_DESCRIPTION}"
        # Use --no-verify (-n) to bypass any pre-commit hooks
        git commit -n -m "$COMMIT_MESSAGE"

        ensure_meta_introspector_remote_and_fork "$repo"

        push_to_origin_branch "$BRANCH_NAME"

    )
    echo "--- Finished $repo ---"
    echo
done

echo "All submodules have been branched and pushed."