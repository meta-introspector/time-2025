#!/usr/bin/env bash

set -e
set -o pipefail

# This script checks if a referenced CRQ document exists in docs/crqs/.

COMMIT_MSG_FILE="$1"

CRQ_ID=$(grep -Eo "^CRQ-[0-9]+" "$COMMIT_MSG_FILE" | head -n 1)

if [ -n "$CRQ_ID" ]; then
  CRQ_FILE="$(dirname "$0")/docs/crqs/${CRQ_ID}.md"
  if [ ! -f "$CRQ_FILE" ]; then
    echo "Error: Commit message references CRQ_ID $CRQ_ID, but $CRQ_FILE does not exist."
    exit 1
  fi
fi

# DEBUG: Always exit 1 to test if hook is triggered
# exit 1
