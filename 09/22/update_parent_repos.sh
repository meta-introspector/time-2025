#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status.
set -e

# Source the lib_git_submodule.sh library
source "/data/data/com.termux.nix/files/home/pick-up-nix2/source/github/meta-introspector/streamofrandom/2025/09/22/lib/lib_git_submodule.sh"

# Helper function to execute commands or just print them in dry-run mode
execute_cmd() {
  if "$DRY_RUN"; then
    echo "DRY RUN: $@"
  else
    "$@"
  fi
}

BRANCH_NAME="crq-808017424794512875886459904961710757005754368000000000"
DRY_RUN=false

# Process the current repository first
echo "----------------------------------------------------"
echo "Processing current repository: $(pwd)"
echo "----------------------------------------------------"

execute_cmd git_add_all

if ! git diff-index --quiet HEAD; then
  echo "Committing changes in current repository..."
  execute_cmd git_commit_message "CRQ-808017424794512875886459904961710757005754368000000000: Commit changes in current repository before updating parents"
  echo "Pushing changes in current repository to origin/$BRANCH_NAME..."
  execute_cmd push_to_origin_branch "$BRANCH_NAME"
else
  echo "No changes to commit in current repository."
fi

echo "Tagging current commit in current repository with branch name: $BRANCH_NAME"
execute_cmd git tag -f "$BRANCH_NAME" # -f to force overwrite if tag exists
execute_cmd git push origin "$BRANCH_NAME" --tags # Push the tag to remote

# Parse arguments
for arg in "$@"; do
  case $arg in
    --dry-run)
      DRY_RUN=true
      shift
      ;;
    *)
      # Unknown option
      shift
      ;;
  esac
done

# Define the repositories and their absolute paths
declare -A REPOS
REPOS["nix2"]="/data/data/com.termux.nix/files/home/pick-up-nix2/"
REPOS["streamofrandom"]="/data/data/com.termux.nix/files/home/pick-up-nix2/source/github/meta-introspector/streamofrandom/"

echo "Updating parent repositories with branch: $BRANCH_NAME"

# Define the order of processing from lowest to highest level
REPO_ORDER=("streamofrandom" "nix2")

for REPO_NAME in "${REPO_ORDER[@]}"; do
  REPO_PATH="${REPOS[$REPO_NAME]}"
  echo "----------------------------------------------------"
  echo "Processing repository: $REPO_NAME at $REPO_PATH"
  echo "----------------------------------------------------"

  # Navigate to the repository directory
  execute_cmd pushd "$REPO_PATH" > /dev/null

  # Check if the branch exists on the remote
  if git ls-remote --heads origin "$BRANCH_NAME" | grep -q "$BRANCH_NAME"; then
    echo "Branch '$BRANCH_NAME' exists on remote. Checking out and pulling."
    CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
    if [ "$CURRENT_BRANCH" != "$BRANCH_NAME" ]; then
      execute_cmd ensure_branch_exists_and_checkout "$BRANCH_NAME"
    else
      echo "Already on branch '$BRANCH_NAME'."
    fi
    execute_cmd git pull origin "$BRANCH_NAME"
  else
    echo "Branch '$BRANCH_NAME' does not exist on remote."
    # Check if the branch exists locally
    if git show-ref --verify --quiet "refs/heads/$BRANCH_NAME"; then
      echo "Branch '$BRANCH_NAME' exists locally. Checking out."
      CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
      if [ "$CURRENT_BRANCH" != "$BRANCH_NAME" ]; then
        execute_cmd ensure_branch_exists_and_checkout "$BRANCH_NAME"
      else
        echo "Already on branch '$BRANCH_NAME'."
      fi
    else
      echo "Branch '$BRANCH_NAME' does not exist locally. Creating and pushing."
      execute_cmd ensure_branch_exists_and_checkout "$BRANCH_NAME"
    fi
    # Ensure the local branch is pushed to remote and upstream is set
    execute_cmd push_to_origin_branch "$BRANCH_NAME"
  fi

  echo "Staging all changes..."
  execute_cmd git_add_all

  # Check if there are any changes to commit
  if ! git diff-index --quiet HEAD; then
    echo "Committing changes..."
    execute_cmd git_commit_message "CRQ-016: Update for flake.nix integration and submodule consistency"
    echo "Pushing changes to origin/$BRANCH_NAME..."
    execute_cmd push_to_origin_branch "$BRANCH_NAME"
  else
    echo "No changes to commit in $REPO_NAME."
  fi

  # Tag the current commit with the branch name
  echo "Tagging current commit with branch name: $BRANCH_NAME"
  execute_cmd git tag -f "$BRANCH_NAME" # -f to force overwrite if tag exists
  execute_cmd git push origin "$BRANCH_NAME" --tags # Push the tag to remote

  # Return to the original directory
  execute_cmd popd > /dev/null
  echo ""
done

echo "All specified repositories processed."