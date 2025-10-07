#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status.
set -e

# Define the directory where the flake is located
FLAKE_DIR="/data/data/com.termux.nix/files/home/pick-up-nix2/source/github/meta-introspector/streamofrandom/2025/09/27/7-concepts/test-secrets-sops"

# Define the secret value for the impure build
# CRITICAL: For sensitive secrets, this value should come from a secure source
# (e.g., a secret manager, not hardcoded in a script committed to Git).
BUILD_SECRET_VALUE="my-impure-secret-value-from-script"

echo "--- Running Impure Build Test ---"

# Navigate to the flake directory
pushd "$FLAKE_DIR" > /dev/null

echo "Attempting to build 'secret-consumer' with BUILD_SECRET_HELLO set..."

# Run the impure build, passing the secret via an environment variable
BUILD_SECRET_HELLO="$BUILD_SECRET_VALUE" nix build .#secret-consumer

echo "Build completed. Verifying output..."

# Verify the output of the build
if [ -f "./result/bin/status.txt" ]; then
  STATUS_MESSAGE=$(cat ./result/bin/status.txt)
  echo "Build Status: $STATUS_MESSAGE"
  if [[ "$STATUS_MESSAGE" == *"successfully accessed"* ]]; then
    echo "Impure build test PASSED."
  else
    echo "Impure build test FAILED: Unexpected status message."
    exit 1
  fi
else
  echo "Impure build test FAILED: status.txt not found."
  exit 1
fi

# Return to the original directory
popd > /dev/null

echo "--- Impure Build Test Finished ---"
