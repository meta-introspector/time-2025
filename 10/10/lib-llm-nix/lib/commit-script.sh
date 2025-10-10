#!/usr/bin/env bash

set -euo pipefail

FLAKE_SOURCE="$1"
PLAN_DERIVATION_PATH="$2"

echo "--- Committing Derived Flake for: ${FLAKE_SOURCE} ---" > "$out"
echo "Content of generated flake.nix:" >> "$out"
cat "${PLAN_DERIVATION_PATH}"/derived-flake/flake.nix >> "$out"
echo "----------------------------------------------------" >> "$out"
echo "This represents the 'architectural closure' for this task." >> "$out"
