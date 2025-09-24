#!/usr/bin/env bash

set -euo pipefail

OUTPUT_FILE="full_flake_output.json"

echo "Dumping full flake output to $OUTPUT_FILE..."
nix flake show --json ./22 --all-systems > "$OUTPUT_FILE"

echo "Full flake output saved to $OUTPUT_FILE. Inspect this file to understand the structure."
