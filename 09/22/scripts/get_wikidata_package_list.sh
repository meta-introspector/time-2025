#!/usr/bin/env bash

set -euo pipefail

# Get the current system
CURRENT_SYSTEM=$(nix-instantiate --eval --expr 'builtins.currentSystem' --json | jq -r .)

# Extract package names using pipes
PACKAGE_ATTRS=$(nix flake show --all-systems ./22 | grep "package '" | sed -E "s/.*: package '(.*)'.*/\1/" | sed -E "s/-wikidata$//" | grep -v "hello-nix")

# Print the extracted package names
echo "Extracted Wikidata package names:"
echo "$PACKAGE_ATTRS"
