#!/usr/bin/env bash

set -e

# This script runs the nixify.sh script on all the Nix-related submodules in vendor/nix.
# It runs in dry-run mode by default. Pass --apply to actually make changes.

APPLY_FLAG=""
if [ "$1" == "--apply" ]; then
  APPLY_FLAG="--apply"
fi

# Extract repository names from flake.nix
# Discover submodules by finding flake.nix files in vendor/nix subdirectories
SUBMODULE_PATHS=$(find vendor/nix -mindepth 2 -maxdepth 2 -type f -name "flake.nix" -print0 | xargs -0 -n1 dirname)

if [ -z "$SUBMODULE_PATHS" ]; then
    echo "No submodules with flake.nix found in vendor/nix"
    exit 1
fi

echo "Found the following submodules to nixify: $SUBMODULE_PATHS"

for submodule_path in $SUBMODULE_PATHS; do
    echo "--- Processing $submodule_path ---"
    ./scripts/nixify.sh "$submodule_path" $APPLY_FLAG
    echo "--- Finished $submodule_path ---"
    echo
done

echo "All submodules in vendor/nix have been processed."