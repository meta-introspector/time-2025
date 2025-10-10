#!/usr/bin/env bash

set -euo pipefail

FLAKE_SOURCE="$1"
INITIAL_FLAKE_CONTENT_PATH="$2"
out="${out:-/dev/stdout}"

echo "--- Evaluating Derived Flake for: ${FLAKE_SOURCE} ---" > "$out"
# Create a temporary directory for the derived flake
TMP_FLAKE_DIR=$(mktemp -d)
echo "Temporary flake directory: $TMP_FLAKE_DIR" >> "$out"

# Write the derived flake content to flake.nix in the temporary directory
cat "${INITIAL_FLAKE_CONTENT_PATH}" > "$TMP_FLAKE_DIR/flake.nix"

# Build the default package of the derived flake
echo "Building default package of derived flake..." >> "$out"
nix build "$TMP_FLAKE_DIR#defaultPackage.x86_64-linux" --print-out-paths >> "$out" 2>&1
BUILD_STATUS=$?

if [ $BUILD_STATUS -eq 0 ]; then
  echo "Derived flake built successfully." >> "$out"
  # Add testing logic here if needed
  echo "Testing derived flake... (placeholder)" >> "$out"
else
  echo "Derived flake build failed." >> "$out"
fi

# Clean up temporary directory
rm -rf "$TMP_FLAKE_DIR"
echo "--- Evaluation Complete ---" >> "$out"
