#!/usr/bin/env bash
#
# Script to initialize a Git repository for storing Nix artifacts.
# This script creates a local clone, sets up the remote, and pushes an initial commit.

set -euo pipefail

# Source the lib_exec.sh library for execute_cmd
source "/data/data/com.termux.nix/files/home/pick-up-nix2/source/github/meta-introspector/streamofrandom/2025/09/22/lib/lib_exec.sh"

# Source the lib_git_submodule.sh library for git operations
source "/data/data/com.termux.nix/files/home/pick-up-nix2/source/github/meta-introspector/streamofrandom/2025/09/22/lib/lib_git_submodule.sh"

REPO_URL="$1"
REPO_NAME=$(basename "$REPO_URL" .git)

execute_cmd echo "Initializing Nix binstore repository: $REPO_NAME from $REPO_URL"

# Create a directory for the local clone
execute_cmd mkdir -p "$REPO_NAME"
execute_cmd cd "$REPO_NAME"

# Initialize Git and add remote
execute_cmd git init
execute_cmd git remote add origin "$REPO_URL"

# Create an initial empty commit to establish the main branch on the remote
execute_cmd git checkout -b main
execute_cmd touch .gitkeep
execute_cmd git add .gitkeep
execute_cmd git commit -m "feat: Initial binstore repository setup"
execute_cmd git push -u origin main

execute_cmd echo "Nix binstore repository '$REPO_NAME' initialized and pushed to '$REPO_URL'."
execute_cmd echo "Local repository is located at: $(pwd)"
