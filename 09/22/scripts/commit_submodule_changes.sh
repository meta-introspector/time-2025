#!/usr/bin/env bash

set -e

SUBMODULE_PATH="$1"
COMMIT_MESSAGE="$2"

if [ -z "$SUBMODULE_PATH" ] || [ -z "$COMMIT_MESSAGE" ]; then
  echo "Usage: $0 <submodule_path> <commit_message>"
  exit 1
fi

echo "Committing changes in submodule: $SUBMODULE_PATH with message: $COMMIT_MESSAGE"

# Navigate into the submodule directory
pushd "$SUBMODULE_PATH"

# Add all changes and commit
git add .
git commit -m "$COMMIT_MESSAGE"

# Navigate back to the original directory
popd

echo "Commit complete for submodule: $SUBMODULE_PATH"
