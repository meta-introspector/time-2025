#!/bin/bash

# This script checks all .nix files to ensure that flake inputs adhere to the
# github:meta-introspector policy. Specifically, it looks for 'nixpkgs.url' and
# 'flake-utils.url' and verifies they point to the meta-introspector forks.

# Exit immediately if a command exits with a non-zero status.
set -e

# Define the allowed GitHub organization
ALLOWED_ORG="github:meta-introspector"

# Define the allowed branches/refs for nixpkgs and flake-utils
ALLOWED_NIXPKGS_REF="feature/CRQ-016-nixify"
ALLOWED_FLAKE_UTILS_REF="feature/CRQ-016-nixify"

# Function to check a single .nix file
check_nix_file() {
  local file="$1"
  local errors=0

  # Check for nixpkgs.url
  if grep -q "nixpkgs.url" "$file"; then
    local actual_nixpkgs_url
    actual_nixpkgs_url=$(grep -E "nixpkgs.url = \"(.*)\";" "$file" | sed -E 's/.*nixpkgs.url = "(.*)".*/\1/')
    if ! grep -E "nixpkgs.url = \"${ALLOWED_ORG}/nixpkgs\?ref=${ALLOWED_NIXPKGS_REF}\";" "$file"; then
      echo "ERROR: ${file}: nixpkgs.url does not adhere to the ${ALLOWED_ORG}/${ALLOWED_NIXPKGS_REF} policy. Found: ${actual_nixpkgs_url}"
      errors=$((errors + 1))
    fi
  fi

  # Check for flake-utils.url
  if grep -q "flake-utils.url" "$file"; then
    local actual_flake_utils_url
    actual_flake_utils_url=$(grep -E "flake-utils.url = \"(.*)\";" "$file" | sed -E 's/.*flake-utils.url = "(.*)".*/\1/')
    if ! grep -E "flake-utils.url = \"${ALLOWED_ORG}/flake-utils\?ref=${ALLOWED_FLAKE_UTILS_REF}\";" "$file"; then
      echo "ERROR: ${file}: flake-utils.url does not adhere to the ${ALLOWED_ORG}/${ALLOWED_FLAKE_UTILS_REF} policy. Found: ${actual_flake_utils_url}"
      errors=$((errors + 1))
    fi
  fi

  # Check for path: references
  if grep -q "url = \"path:" "$file"; then
    echo "ERROR: ${file}: Found 'path:' reference in a flake URL. Only github:meta-introspector URLs are allowed."
    errors=$((errors + 1))
  fi

  return $errors
}

# Find all .nix files and check them
NIX_FILES=$(find . -name "*.nix" -print0 | xargs -0)
TOTAL_ERRORS=0

if [ -z "$NIX_FILES" ]; then
  echo "No .nix files found to check."
else
  echo "Checking Nix flake URLs..."
  for nix_file in $NIX_FILES;
do
    check_nix_file "$nix_file" || TOTAL_ERRORS=$((TOTAL_ERRORS + 1))
  done
fi

if [ $TOTAL_ERRORS -gt 0 ]; then
  echo "Nix URL check failed with ${TOTAL_ERRORS} errors."
  exit 1
else
  echo "Nix URL check passed. All flake inputs adhere to the meta-introspector policy."
  exit 0
fi
