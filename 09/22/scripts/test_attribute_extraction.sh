#!/usr/bin/env bash

set -euo pipefail

# Get the current system
nix-instantiate --eval --expr 'builtins.currentSystem' --json > current_system.txt
CURRENT_SYSTEM=$(cat current_system.txt)

# Get the raw output of nix flake show ./22
#FLAKE_SHOW_OUTPUT=
nix flake show . --json --all-systems > flake22.json

# Extract attribute names
grep  "packages.${CURRENT_SYSTEM}.*html" flake22.json > step1.txt

sed -E "s/.*packages.${CURRENT_SYSTEM}\.(.*):.*/\1/" step1.txt | tr -d '"' | grep -E "-wikidata$" 

# Print the extracted attribute names
echo "Extracted Wikidata package attributes:"
echo "$PACKAGE_ATTRS"
