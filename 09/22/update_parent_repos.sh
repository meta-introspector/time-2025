#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status.
set -e

# Initialize DRY_RUN to false by default
DRY_RUN=false

TAGS_ENABLED=false # Initialize to false by default

# Parse arguments
for arg in "$@"; do
  case $arg in
    --dry-run)
      DRY_RUN=true
      shift
      ;;
    --tags)
      TAGS_ENABLED=true
      shift
      ;;
    *)
      # Unknown option
      shift
      ;;
  esac
done

# Export DRY_RUN so it's available in sourced scripts
export DRY_RUN

# Source the lib_exec.sh library for execute_cmd
source "/data/data/com.termux.nix/files/home/pick-up-nix2/source/github/meta-introspector/streamofrandom/2025/09/22/lib/lib_exec.sh"

# Source the lib_git_submodule.sh library
source "/data/data/com.termux.nix/files/home/pick-up-nix2/source/github/meta-introspector/streamofrandom/2025/09/22/lib/lib_git_submodule.sh"

BRANCH_NAME="feature/808017424794512875886459904961710757005754368000000000"
COMMIT_MESSAGE="CRQ-016: Update for flake.nix integration and submodule consistency"

execute_cmd echo "Updating parent repositories with branch: $BRANCH_NAME"

# Process the current repository first
process_single_repo "." "$BRANCH_NAME" "$COMMIT_MESSAGE" "$TAGS_ENABLED"

# Define the other repositories and their absolute paths
declare -A REPOS
REPOS["nix2"]="/data/data/com.termux.nix/files/home/pick-up-nix2/"
REPOS["streamofrandom"]="/data/data/com.termux.nix/files/home/pick-up-nix2/source/github/meta-introspector/streamofrandom/"



process_single_repo "${REPOS["streamofrandom"]}" "$BRANCH_NAME" "$COMMIT_MESSAGE" "$TAGS_ENABLED"
process_single_repo "${REPOS["nix2"]}" "$BRANCH_NAME" "$COMMIT_MESSAGE" "$TAGS_ENABLED"

execute_cmd echo "All specified repositories processed."