#!/usr/bin/env bash
#
# Script to initialize a Git repository for storing Nix artifacts.
# This script creates a local clone, sets up the remote, and pushes an initial commit.

set -euo pipefail

REPO_URL="$1"
REPO_NAME=$(basename "$REPO_URL" .git)

echo "Initializing Nix binstore repository: $REPO_NAME from $REPO_URL"

# Create a directory for the local clone
mkdir -p "$REPO_NAME"
cd "$REPO_NAME"

# Initialize Git and add remote
git init
git remote add origin "$REPO_URL"

# Create an initial empty commit to establish the main branch on the remote
git checkout -b main
touch .gitkeep
git add .gitkeep
git commit -m "feat: Initial binstore repository setup"
git push -u origin main

echo "Nix binstore repository '$REPO_NAME' initialized and pushed to '$REPO_URL'."
echo "Local repository is located at: $(pwd)"
