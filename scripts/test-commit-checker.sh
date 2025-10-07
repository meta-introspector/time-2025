#!/usr/bin/env bash

# This script tests the commit message checker against the last N commits.
# It now orchestrates smaller, modular scripts.

set -euo pipefail

# Source configuration
source "./scripts/test-commit-checker/config.sh"

echo "--- Testing commit message checker against the last ${NUM_COMMITS} commits ---"

# Counter for passed/failed checks
PASSED_COUNT=0
FAILED_COUNT=0

# Get the last N commit messages, separated by the custom delimiter
# Use a temporary file to store the output to avoid issues with process substitution and read -d
TEMP_COMMIT_LOG=$(mktemp)
./scripts/test-commit-checker/get-commit-messages.sh "${NUM_COMMITS}" > "$TEMP_COMMIT_LOG"

# Read commit entries using the custom delimiter
while IFS= read -r -d '' COMMIT_ENTRY; do
  # Remove any leading/trailing whitespace or newlines that might be left from the delimiter
  COMMIT_ENTRY=$(echo "$COMMIT_ENTRY" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')

  # Skip empty entries that might result from parsing
  if [[ -z "$COMMIT_ENTRY" ]]; then
    continue
  fi

  # Process each commit message and capture its output
  RESULT=$(./scripts/test-commit-checker/process-commit-message.sh "${COMMIT_ENTRY}" "${CHECK_SINGLE_MSG_SCRIPT}")

  if [[ "$RESULT" == "PASS" ]]; then
    PASSED_COUNT=$((PASSED_COUNT + 1))
  else
    FAILED_COUNT=$((FAILED_COUNT + 1))
  fi
done < <(tr '\n' '\0' < "$TEMP_COMMIT_LOG" | sed 's/---COMMIT-DELIMITER---\x00/\x00/g')

# Clean up the temporary file
rm "$TEMP_COMMIT_LOG"

# Report summary and exit
./scripts/test-commit-checker/report-summary.sh "${PASSED_COUNT}" "${FAILED_COUNT}"
