#!/usr/bin/env bash

# This script automates the setup of pre-commit hooks for the project.
# It ensures that the Nix development environment is loaded and then
# installs the Git pre-commit hooks using the 'pre-commit' tool.

# Exit immediately if a command exits with a non-zero status.
set -e

# Define the project directory (current working directory)
PROJECT_DIR="/data/data/com.termux.nix/files/home/pick-up-nix2/source/github/meta-introspector/streamofrandom/2025/09/27/"

echo "Navigating to project directory: $PROJECT_DIR"
cd "$PROJECT_DIR"

echo "Entering Nix development shell and installing pre-commit hooks..."
# Use nix develop --command to execute pre-commit install within the
# development environment. This ensures all necessary tools (like pre-commit)
# are available.
nix develop --command bash -c "pre-commit install --hook-type pre-commit --hook-type commit-msg"

echo "Pre-commit hooks setup complete. They will now run automatically on git commit."
echo "You can test them by trying to commit a file that violates a hook rule."
