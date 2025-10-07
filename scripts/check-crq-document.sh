#!/usr/bin/env bash
set -euo pipefail

COMMIT_MSG_FILE="$1"

# Build the script and get its store path
SCRIPT_PATH=$(nix build .#crqDocumentCheck.packages.aarch64-linux.crq-document-check-script --no-link --print-out-paths)

# Execute the script with the commit message file
NIX_OUTPUT=$("$SCRIPT_PATH/bin/crq-document-check" "$COMMIT_MSG_FILE")

# Parse the JSON output
SUCCESS=$(echo "$NIX_OUTPUT" | jq -r '.success')
MESSAGE=$(echo "$NIX_OUTPUT" | jq -r '.message')

if [ "$SUCCESS" = "false" ]; then
  echo "$MESSAGE" >&2
  exit 1
else
  exit 0
fi
