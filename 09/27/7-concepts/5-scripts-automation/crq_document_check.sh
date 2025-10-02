#!/usr/bin/env bash

set -e
set -o pipefail

# This script checks if a referenced CRQ document exists in docs/crqs/.

COMMIT_MSG_FILE="$1"

CRQ_ID=$(grep -Eo "CRQ-[0-9]+" "$COMMIT_MSG_FILE" | head -n 1)

echo "DEBUG: CRQ_ID = '$CRQ_ID'" >&2

if [ -n "$CRQ_ID" ]; then
  echo "DEBUG: CRQ_ID is not empty." >&2
  CRQ_FILE="$(dirname "$0")/docs/crqs/${CRQ_ID}.md"
  echo "Current working directory: $(pwd)" >&2
  echo "CRQ_FILE: $CRQ_FILE" >&2
  if [ ! -f "$CRQ_FILE" ]; then
    echo "Error: Commit message references CRQ_ID $CRQ_ID, but $CRQ_FILE does not exist." >&2
    exit 1
  fi
else
  echo "DEBUG: CRQ_ID is empty." >&2
fi

# DEBUG: Always exit 1 to test if hook is triggered
# exit 1
