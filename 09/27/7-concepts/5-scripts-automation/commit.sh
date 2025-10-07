#!/usr/bin/env bash

# This script runs pre-commit hooks and then git commit within the Nix development environment,
# ensuring that pre-commit hooks defined in flake.nix are active and have the correct PATH.

# Ensure the Nix development environment is loaded for pre-commit and then execute git commit.
# All arguments passed to commit.sh will be forwarded to git commit.

echo "Running pre-commit hooks within Nix development environment..."
nix develop --command bash -c 'pre-commit run --all-files'
PRE_COMMIT_STATUS=$?

if [ $PRE_COMMIT_STATUS -ne 0 ]; then
  echo "Pre-commit hooks failed. Aborting commit."
  exit $PRE_COMMIT_STATUS
fi

echo "Pre-commit hooks passed. Proceeding with git commit..."
nix develop --command bash -c 'git commit "$@"' -- "$@"
