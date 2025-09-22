#!/usr/bin/env bash

set -e

SUBMODULE_PATH="$1"

if [ -z "$SUBMODULE_PATH" ]; then
  echo "Usage: $0 <submodule_path>"
  exit 1
fi

echo "Setting up submodule: $SUBMODULE_PATH"

# Navigate into the submodule directory
pushd "$SUBMODULE_PATH"

# Run the submodule's setup script
if [ -f scripts/setup_gemini_context.sh ]; then
  ./scripts/setup_gemini_context.sh
else
  echo "Warning: scripts/setup_gemini_context.sh not found in $SUBMODULE_PATH"
fi

# Run the submodule's build script if it exists
if [ -f scripts/build.sh ]; then
  ./scripts/build.sh
else
  echo "Warning: scripts/build.sh not found in $SUBMODULE_PATH"
fi

# Run the submodule's test script if it exists
if [ -f scripts/test.sh ]; then
  ./scripts/test.sh
else
  echo "Warning: scripts/test.sh not found in $SUBMODULE_PATH"
fi

# Navigate back to the original directory
popd

echo "Submodule setup complete for: $SUBMODULE_PATH"