#!/usr/bin/env bash
set -euo pipefail

echo "Testing evaluation of nar-binstore-builder flake's lib.allNars..."

# Evaluate the lib.allNars output from the flake
# We need to specify a system, for example, x86_64-linux.
# Note: This assumes the current shell has access to Nix and the flake inputs.
nar_list_raw=$(nix eval --raw ../../10/11/nar-binstore-builder#lib.x86_64-linux.allNars)

echo "Evaluated NAR list (raw):"
echo "$nar_list_raw"

# Assert that the raw NAR list is not empty
if [[ -z "$nar_list_raw" ]]; then
  echo "Error: Evaluated NAR list is empty." >&2
  exit 1
fi

echo "Test successful: NAR list evaluated and is not empty."
