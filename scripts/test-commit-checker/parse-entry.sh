#!/usr/bin/env bash

# Cleans up a commit entry by removing leading/trailing whitespace and newlines.
# Usage: parse-entry.sh <COMMIT_ENTRY>

set -euo pipefail

COMMIT_ENTRY="$1"

echo "$COMMIT_ENTRY" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//'
