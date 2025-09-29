#!/usr/bin/env bash

# Define the base directory for relative paths
BASE_DIR="/data/data/com.termux.nix/files/home/pick-up-nix2/"

# Define the search pattern
SEARCH_PATTERN='statix|nixpkgs-fmt|nix-linter|pre-commit-hooks|git-hooks-nix|commitlint'

# Read pre-commit.txt line by line
while IFS= read -r relative_path; do
  # Construct the absolute path
  absolute_path="${BASE_DIR}${relative_path#./}" # Remove leading ./ if present

  # Check if the file exists before grepping
  if [ -f "$absolute_path" ]; then
    echo "--- Grepping in: $absolute_path ---"
    grep -E "$SEARCH_PATTERN" "$absolute_path"
  else
    echo "--- File not found: $absolute_path ---"
  fi
done < "/data/data/com.termux.nix/files/home/pick-up-nix2/index/pre-commit.txt"
