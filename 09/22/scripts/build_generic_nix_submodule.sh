#!/usr/bin/env bash

# SOP: Build Generic Nix Submodule
# This script builds a generic Nix submodule.

OFFLINE_MODE=""
SUBMODULE_PATH=""

# Parse arguments
while [[ "$#" -gt 0 ]]; do
    case "$1" in
        --offline)
            OFFLINE_MODE="--offline"
            shift
            ;; 
        *)
            if [ -z "$SUBMODULE_PATH" ]; then
                SUBMODULE_PATH="$1"
            else
                echo "Unknown option or too many arguments: $1"
                echo "Usage: $0 [--offline] <path_to_nixtract_submodule>"
                echo "Example: $0 --offline vendor/nix/nixtract"
                exit 1
            fi
            shift
            ;; 
    esac
done

# Check if a submodule path is provided
if [ -z "$SUBMODULE_PATH" ]; then
  echo "Usage: $0 [--offline] <path_to_nix_submodule>"
  echo "Example: $0 --offline vendor/nix/my-submodule"
  exit 1
fi

FULL_SUBMODULE_PATH="$(realpath "$SUBMODULE_PATH")"

echo "Attempting to build Nix submodule at: $FULL_SUBMODULE_PATH"
echo "Offline mode: ${OFFLINE_MODE:-\"disabled\"}"

echo "--- Nix Build Plan (Dry Run) ---"
nix build "$FULL_SUBMODULE_PATH"# --dry-run $OFFLINE_MODE --extra-experimental-features "flakes nix-command" > nixtract_build_plan.log 2>&1

if [ $? -ne 0 ]; then
  echo "Error: Dry run failed. Please check the flake configuration or ensure all dependencies are available locally if in offline mode."
  cat nixtract_build_plan.log # Print the log for debugging
  exit 1
fi

echo "Dry run output saved to nixtract_build_plan.log"

echo "--- Starting Actual Nix Build ---"
if nix build "$FULL_SUBMODULE_PATH"# $OFFLINE_MODE --extra-experimental-features "flakes nix-command"; then
  echo "Nix submodule built successfully!"
  echo "You can find the result in: $(nix build --no-link --print-out-paths "$FULL_SUBMODULE_PATH"# $OFFLINE_MODE)"
else
  echo "Error: Failed to build Nix submodule."
  exit 1
fi
