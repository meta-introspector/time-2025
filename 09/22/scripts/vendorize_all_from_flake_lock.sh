#!/usr/bin/env bash

set -euo pipefail

# This script reads a flake.lock file and attempts to vendorize all GitHub repositories found within it.
# It uses the vendorize_and_fork_submodule.sh script for the actual vendorization.

FLAKE_LOCK_FILE=""
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
      FLAKE_LOCK_FILE="$1"
      shift # past argument
      ;;
  esac
done

if [ -z "$FLAKE_LOCK_FILE" ]; then
    echo "Usage: $0 [--dry-run] <path_to_flake.lock>"
    echo "Example: $0 --dry-run ./flake.lock"
    exit 1
fi

if [ ! -f "$FLAKE_LOCK_FILE" ]; then
    echo "Error: flake.lock file not found at $FLAKE_LOCK_FILE"
    exit 1
fi

if [ "$DRY_RUN" = "true" ]; then
  echo "Running in DRY-RUN mode. No changes will be made."
fi

# Extract GitHub repository URLs from flake.lock
# We are looking for nodes that have type: "github" and extract owner and repo.
# We also need to handle the case where the original URL is a github: shorthand.

REPOS=$(jq -r '.nodes | to_entries[] | select(.value.locked.type == "github") | .value.locked.owner + ":" + .value.locked.repo + " " + .key' "$FLAKE_LOCK_FILE")

if [ -z "$REPOS" ]; then
    echo "No GitHub repositories found in $FLAKE_LOCK_FILE to vendorize."
    exit 0
fi

echo "Found GitHub repositories in $FLAKE_LOCK_FILE:"
echo "--------------------------------------------------"

while IFS= read -r line; do
    ORIGINAL_REPO_SHORTHAND=$(echo "$line" | awk '{print $1}')
    NODE_KEY=$(echo "$line" | awk '{print $2}')

    # Construct a plausible submodule path. This is a heuristic and might need refinement.
    # For simplicity, let's assume a structure like vendor/nix/<repo_name>
    # This needs to be more robust for real-world scenarios.
    # Extract owner and repo from the shorthand
    OWNER=$(echo "$ORIGINAL_REPO_SHORTHAND" | cut -d':' -f1)
    REPO=$(echo "$ORIGINAL_REPO_SHORTHAND" | cut -d':' -f2)
    SUBMODULE_PATH="vendor/${OWNER}/${REPO}"

    echo "Processing $ORIGINAL_REPO_SHORTHAND (Node: $NODE_KEY)"
    if [ "$DRY_RUN" = "true" ]; then
        ./scripts/vendorize_and_fork_submodule.sh --dry-run "$ORIGINAL_REPO_SHORTHAND" "$SUBMODULE_PATH" "$REPO"
    else
        ./scripts/vendorize_and_fork_submodule.sh "$ORIGINAL_REPO_SHORTHAND" "$SUBMODULE_PATH" "$REPO"
    fi
    echo "--------------------------------------------------"
done <<< "$REPOS"

echo "Vendorization process completed."
