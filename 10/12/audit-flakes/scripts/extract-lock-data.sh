#!/usr/bin/env bash
set -euo pipefail

if [ -z "$1" ]; then
  echo "Usage: $0 <path_to_all_processed_locks.json>"
  exit 1
fi

ALL_PROCESSED_LOCKS_JSON="$1"

echo "Extracting data from: $ALL_PROCESSED_LOCKS_JSON"

# Example: Extracting nixFilePath and lockFilePath from each entry
jq -c '.[] | {nixFilePath, lockFilePath, processedAt}' "$ALL_PROCESSED_LOCKS_JSON"
