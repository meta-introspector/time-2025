#!/usr/bin/env bash

set -euo pipefail

source "$(dirname "$0")"/lib_github_parsing.sh

# This script updates the flake.lock file based on the URLs in the
# index/flake_nix_urls_with_filenames.txt file.

INPUT_FILE="index/flake_nix_urls_with_filenames.txt"

# Read the input file and extract the dependency names
DEPS=$(cat "$INPUT_FILE" | while read -r line; do
    # Extract the github:owner/repo part
    github_flake_input=$(echo "$line" | grep -o 'github:[^/"]\+/[^/"]\+')
    if [[ -n "$github_flake_input" ]]; then
        get_repo_name_from_github_flake_input "$github_flake_input"
    fi
done | sort -u)

# Build the nix flake lock command
CMD="nix flake lock"
for dep in $DEPS; do
  CMD="$CMD --update-input $dep"
done

# Run the command
echo "Running: $CMD"
$CMD