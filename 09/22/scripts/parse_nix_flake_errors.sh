#!/usr/bin/env bash

# parse_nix_flake_errors.sh
# Parses Nix flake error output to identify problematic GitHub repositories.

if [ -z "$1" ]; then
    echo "Usage: $0 <error_log_file>"
    echo "       Or: cat <error_log_file> | $0"
    exit 1
fi

# Read from file or stdin
if [ -f "$1" ]; then
    INPUT_SOURCE="$1"
else
    INPUT_SOURCE="/dev/stdin"
fi

echo "Repositories with missing branches (feature/CRQ-016-nixify-workflow):"
grep -oP 'github:meta-introspector/[^/]+' "$INPUT_SOURCE" | sort -u | while read -r repo; do
    echo "- $repo"
done
