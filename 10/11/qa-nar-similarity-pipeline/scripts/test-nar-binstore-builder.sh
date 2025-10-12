#!/usr/bin/env bash
set -euo pipefail

echo "Testing nar-binstore-builder flake..."

# Build the nar-binstore-builder flake and get its allNars output
# The output of lib.allNars is a list of paths, which nix build will put into a file.
nar_list_path=$(nix build ../nar-binstore-builder#lib.allNars --no-link --print-out-paths)
nar_list=$(cat "$nar_list_path")

echo "Generated NAR list:"
echo "$nar_list"

# Assert that the NAR list is not empty
if [[ -z "$nar_list" ]]; then
  echo "Error: NAR list is empty." >&2
  exit 1
fi

# Further assertions could be added here to check the format or content of the NAR paths

echo "Test successful: nar-binstore-builder generated a non-empty list of NARs."
