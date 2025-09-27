#!/usr/bin/env bash

# This script tests the crq_document_check.sh pre-commit hook.

# Define paths
CRQ_DOCUMENT_CHECK_SCRIPT="/data/data/com.termux.nix/files/home/pick-up-nix2/source/github/meta-introspector/streamofrandom/2025/09/27/crq_document_check.sh"
CRQ_DOCS_DIR="/data/data/com.termux.nix/files/home/pick-up-nix2/source/github/meta-introspector/streamofrandom/2025/09/27/docs/crqs/"
TEMP_COMMIT_MSG_FILE="temp_commit_msg.txt"

echo "--- Running CRQ Document Check Tests ---"

# Test Case 1: CRQ-ID in commit message, but CRQ document does NOT exist
echo "Test Case 1: CRQ-ID in commit message (CRQ-999), CRQ document does NOT exist"
echo "CRQ-999: This is a test commit message for a non-existent CRQ." > "$TEMP_COMMIT_MSG_FILE"
if "$CRQ_DOCUMENT_CHECK_SCRIPT" "$TEMP_COMMIT_MSG_FILE"; then
  echo "FAIL: Hook passed unexpectedly for non-existent CRQ document."
else
  echo "PASS: Hook correctly failed for non-existent CRQ document."
fi
rm "$TEMP_COMMIT_MSG_FILE"

# Test Case 2: CRQ-ID in commit message, and CRQ document EXISTS
echo "Test Case 2: CRQ-ID in commit message (CRQ-XXXX), CRQ document EXISTS"
# Create a dummy CRQ document for this test
echo "## CRQ-XXXX" > "${CRQ_DOCS_DIR}CRQ-XXXX.md"
echo "CRQ-XXXX: This is a test commit message for an existing CRQ." > "$TEMP_COMMIT_MSG_FILE"
if "$CRQ_DOCUMENT_CHECK_SCRIPT" "$TEMP_COMMIT_MSG_FILE"; then
  echo "PASS: Hook correctly passed for existing CRQ document."
else
  echo "FAIL: Hook failed unexpectedly for existing CRQ document."
fi
rm "$TEMP_COMMIT_MSG_FILE"
rm "${CRQ_DOCS_DIR}CRQ-XXXX.md" # Clean up dummy CRQ document

# Test Case 3: No CRQ-ID in commit message
echo "Test Case 3: No CRQ-ID in commit message (conventional commit)"
echo "feat: This is a conventional commit message." > "$TEMP_COMMIT_MSG_FILE"
if "$CRQ_DOCUMENT_CHECK_SCRIPT" "$TEMP_COMMIT_MSG_FILE"; then
  echo "PASS: Hook correctly passed for commit message without CRQ-ID."
else
  echo "FAIL: Hook failed unexpectedly for commit message without CRQ-ID."
fi
rm "$TEMP_COMMIT_MSG_FILE"

echo "--- CRQ Document Check Tests Complete ---"
