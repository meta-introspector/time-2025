#!/usr/bin/env bash

set -e

SUBMODULE_PATH="$1"

if [ -z "$SUBMODULE_PATH" ]; then
  echo "Usage: $0 <submodule_path>"
  exit 1
fi

echo "Running setup_gemini_context.sh in submodule: $SUBMODULE_PATH"

# Navigate into the submodule directory
pushd "$SUBMODULE_PATH"

# Execute the submodule's setup script
if [ -f scripts/setup_gemini_context.sh ]; then
  ./scripts/setup_gemini_context.sh
else
  echo "Error: scripts/setup_gemini_context.sh not found in $SUBMODULE_PATH"
  exit 1
fi

# Navigate back to the original directory
popd

echo "Setup complete for submodule: $SUBMODULE_PATH"
