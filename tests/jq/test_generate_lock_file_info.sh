#!/usr/bin/env bash

set -euo pipefail

JQ_SCRIPT="/data/data/com.termux.nix/files/home/pick-up-nix2/source/github/meta-introspector/streamofrandom/2025/scripts/jq/generate_lock_file_info.jq"

# Test Case 1: Basic input
NIX_FILE_PATH_TEST="/path/to/flake.nix"
LOCK_FILE_PATH_TEST="/path/to/flake.lock"
BAG_OF_WORDS_TEST='{"foo":"2","bar":"1"}'

EXPECTED_OUTPUT='{"nixFilePath":"/path/to/flake.nix","lockFilePath":"/path/to/flake.lock","bagOfWords":{"foo":"2","bar":"1"},"hasLockFile":true}'

ACTUAL_OUTPUT=$(jq -n -c \
  --arg nixFilePath "$NIX_FILE_PATH_TEST" \
  --arg lockFilePath "$LOCK_FILE_PATH_TEST" \
  --argjson bagOfWords "$BAG_OF_WORDS_TEST" \
  -f "$JQ_SCRIPT")

if [[ "$ACTUAL_OUTPUT" == "$EXPECTED_OUTPUT" ]]; then
  echo "Test Case 1 Passed: Basic input"
else
  echo "Test Case 1 Failed: Basic input"
  echo "Expected: $EXPECTED_OUTPUT"
  echo "Actual:   $ACTUAL_OUTPUT"
  exit 1
fi

echo "All tests for generate_lock_file_info.jq passed."
