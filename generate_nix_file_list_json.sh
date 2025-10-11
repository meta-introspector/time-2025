#!/usr/bin/env bash

# This script simulates the output of the nix eval command from flake.nix
# It takes a JSON string of flakePaths as its first argument.

FLAKE_PATHS_JSON="$1"

if [ -z "$FLAKE_PATHS_JSON" ]; then
  echo "Usage: $0 <JSON_FLAKE_PATHS>"
  exit 1
fi

# In a real scenario, getNixFileList would process FLAKE_PATHS_JSON
# and return a filtered list of Nix files.
# For this simulation, we'll just echo a dummy JSON output.
# We'll assume the input flakePaths are already filtered to .nix files for simplicity.

# Example output: ["/path/to/flake1.nix", "/path/to/flake2.nix"]
echo "$FLAKE_PATHS_JSON" > nix-file-list.json

echo "Simulated nix-file-list.json created."
cat nix-file-list.json
