#!/usr/bin/env bash

set -euo pipefail

source "$(dirname "$0")"/lib_github_parsing.sh

# This script generates a list of dependencies to update.

INPUT_FILE="index/flake_nix_urls_with_filenames.txt"
OUTPUT_FILE="index/dependency_update_list.txt"

# Read the input file and extract the dependency names
cat "$INPUT_FILE" | while read -r line; do
    # Extract the github:owner/repo part
    github_flake_input=$(echo "$line" | grep -o 'github:[^/"]\+/[^?" ]\+' | sed -e 's/\?.*//' -e 's/\.nix//' -e 's/;//')
    if [[ -n "$github_flake_input" ]]; then
        get_repo_name_from_github_flake_input "$github_flake_input"
    fi
done | sort -u > "$OUTPUT_FILE"

echo "Dependency list generated at: $OUTPUT_FILE"