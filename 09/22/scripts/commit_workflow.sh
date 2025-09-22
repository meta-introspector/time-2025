#!/usr/bin/env bash

set -e

# --- Configuration ---
BRANCH_NAME="feature/CRQ-016-nixify-workflow"
COMMIT_MESSAGE_FILE=".git_commit_message.txt"

# --- 1. Create or Checkout Branch ---
echo "--- Creating or checking out branch: $BRANCH_NAME ---"
if git rev-parse --verify "$BRANCH_NAME" &>/dev/null; then
    echo "Branch $BRANCH_NAME already exists. Checking it out."
    git checkout "$BRANCH_NAME"
else
    echo "Branch $BRANCH_NAME does not exist. Creating and checking it out."
    git checkout -b "$BRANCH_NAME"
fi

# --- 2. Stage Files ---
echo "--- Staging all new and modified files ---"
git add .

# --- 3. Generate Commit Message using Rust Templating Tool ---
echo "--- Generating commit message using Rust templating tool ---"
# Call the template_generator_bin from its actual build path
COMMIT_MESSAGE_CONTENT=$(./scripts/run_template_generator.sh commit-message "016" "Standardize flake.nix from template and refactor commit workflow")

# --- 4. Create Commit Message File ---
echo "--- Creating commit message file ---
"
echo "$COMMIT_MESSAGE_CONTENT" > "$COMMIT_MESSAGE_FILE"

# --- 5. Commit ---
echo "--- Committing changes ---
"
git commit -F "$COMMIT_MESSAGE_FILE"

echo "--- Commit successful! ---"
