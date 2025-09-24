#!/usr/bin/env bash

set -euo pipefail

# Get the current system
CURRENT_SYSTEM=$(nix-instantiate --eval --expr 'builtins.currentSystem' --json | jq -r .)

# Get the raw output of nix flake show ./22
FLAKE_SHOW_OUTPUT=$(nix flake show ./22)

# Extract attribute names
PACKAGE_ATTRS=$(echo "$FLAKE_SHOW_OUTPUT" | grep "packages.${CURRENT_SYSTEM//-/\\-}\\..*html" | sed -E "s/.*packages.${CURRENT_SYSTEM//-/\\-}\\.(.*):.*/\\1/" | tr -d '"' | grep -E "-wikidata$")

# Print the extracted attribute names
echo "Extracted Wikidata package attributes:"
echo "$PACKAGE_ATTRS"
