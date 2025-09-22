#!/usr/bin/env bash

# This script commits changes within a specified submodule, associating them with a CRQ.

set -euo pipefail

if [ -z "$2" ]; then
  echo "Usage: $0 <SUBMODULE_PATH> <CRQ_NUMBER> [COMMIT_MESSAGE_DESCRIPTION]"
  echo "Example: $0 vendor/nix/nixtract 123 \"Implement feature X\""
  exit 1
fi

SUBMODULE_PATH="$1"
CRQ_NUMBER="$2"
COMMIT_MESSAGE_DESCRIPTION="${3:-'Automated commit for CRQ'}" # Default message if not provided

ROOT_DIR="/data/data/com.termux.nix/files/home/pick-up-nix2"
FULL_SUBMODULE_PATH="${ROOT_DIR}/${SUBMODULE_PATH}"

echo "Committing changes in ${FULL_SUBMODULE_PATH} for CRQ-${CRQ_NUMBER}"

# Navigate to the submodule directory
pushd "${FULL_SUBMODULE_PATH}" > /dev/null

# Stage all changes
git add .

# Check if there are any changes to commit
if git diff --staged --quiet; then
  echo "No changes to commit."
else
  # Construct the commit message
  COMMIT_MESSAGE="feat($(basename "$SUBMODULE_PATH")): CRQ-${CRQ_NUMBER} - ${COMMIT_MESSAGE_DESCRIPTION}"
  # Commit the changes, bypassing hooks
  git commit -n -m "${COMMIT_MESSAGE}"
fi

# Return to the original directory
popd > /dev/null

echo "Commit successful for CRQ-${CRQ_NUMBER} in ${SUBMODULE_PATH}."
