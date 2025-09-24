#!/usr/bin/env bash

set -euo pipefail

# Extract package names using jq
PACKAGE_NAMES=$(nix flake show --json ./22 | jq -r '.packages."aarch64-linux" | to_entries[] | select(.value.name | endswith("-wikidata")) | .key')

# Print the extracted package names
echo "Extracted Wikidata package names:"
echo "$PACKAGE_NAMES"
