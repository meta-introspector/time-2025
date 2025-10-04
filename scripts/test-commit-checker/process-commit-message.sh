#!/usr/bin/env bash

# Processes a single commit message, checks it, and reports the result.
# Usage: process-commit-message.sh <COMMIT_ENTRY> <CHECK_SINGLE_MSG_SCRIPT>

set -euo pipefail

COMMIT_ENTRY="$1"
CHECK_SINGLE_MSG_SCRIPT="$2"

# Parse the commit entry
COMMIT_HASH=$(echo "${COMMIT_ENTRY}" | awk -F'---FIELD-DELIMITER---' '{print $1}')
COMMIT_SUBJECT=$(echo "${COMMIT_ENTRY}" | awk -F'---FIELD-DELIMITER---' '{print $2}')
COMMIT_BODY=$(echo "${COMMIT_ENTRY}" | awk -F'---FIELD-DELIMITER---' '{print $3}')

# The actual commit message to check is the subject + body
COMMIT_MSG_TO_CHECK="${COMMIT_SUBJECT}\n\n${COMMIT_BODY}"

# Skip empty messages that might result from parsing
if [[ -z "${COMMIT_MSG_TO_CHECK}" ]]; then
  echo "PASS" # Treat as passed if empty, or handle as an error if preferred
  exit 0
fi

printf "\n--- Checking commit: %s ---\nSubject: %s\n'''\n%s\n'''\n" "${COMMIT_HASH}" "${COMMIT_SUBJECT}" "${COMMIT_BODY}" >&2

# Create a temporary file for the commit message
TEMP_MSG_FILE=$(mktemp)
echo "${COMMIT_MSG_TO_CHECK}" > "$TEMP_MSG_FILE"

# Execute the helper script to check the commit message
if "${CHECK_SINGLE_MSG_SCRIPT}" "${TEMP_MSG_FILE}"; then
  echo "PASS"
  rm "$TEMP_MSG_FILE"
  exit 0
else
  echo "FAIL"
  rm "$TEMP_MSG_FILE"
  exit 0 # Always exit 0 here, the PASS/FAIL string is the indicator
fi