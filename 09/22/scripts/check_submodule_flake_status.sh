#!/usr/bin/env bash

set -e

if [ -z "$1" ]; then
  echo "Usage: $0 <SUBMODULE_PATH>"
  echo "Example: $0 vendor/nix/nixtract"
  exit 1
fi

SUBMODULE_PATH="$1"
FULL_SUBMODULE_PATH="/data/data/com.termux.nix/files/home/pick-up-nix2/${SUBMODULE_PATH}"

echo "--- Checking status for submodule: ${SUBMODULE_PATH} ---"

# 1. Check Git Status
echo "Git Status (local):"
(cd "${FULL_SUBMODULE_PATH}" && git status)

echo ""

# 2. Check Flake Version (nixpkgs input URL)
echo "Flake Version (nixpkgs input URL from flake.nix):"
FLAKE_NIX_PATH="${FULL_SUBMODULE_PATH}/flake.nix"
if [ -f "${FLAKE_NIX_PATH}" ]; then
    NIXPKGS_URL=$(grep -E 'nixpkgs\.url\s*=' "${FLAKE_NIX_PATH}" | awk -F'"' '{print $2}')
    if [ -n "${NIXPKGS_URL}" ]; then
        echo "  Nixpkgs URL: ${NIXPKGS_URL}"
    else
        echo "  Nixpkgs URL not found in ${FLAKE_NIX_PATH}"
    fi
else
    echo "  flake.nix not found in ${FLAKE_NIX_PATH}"
fi

echo ""

# 3. Report on differences (conceptual, based on output above)
echo "--- Report on Differences ---"
echo "Review the 'Git Status (local)' output for any uncommitted changes, untracked files, or differences with the remote."
echo "Review the 'Flake Version' to see which nixpkgs version is being used locally."
echo "To compare with remote Git status, you would typically fetch and then diff, but this script focuses on local status and flake version."

echo "--- Finished checking ${SUBMODULE_PATH} ---"
