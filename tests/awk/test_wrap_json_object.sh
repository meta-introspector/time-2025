#!/usr/bin/env bash

set -euo pipefail

AWK_SCRIPT="/data/data/com.termux.nix/files/home/pick-up-nix2/source/github/meta-introspector/streamofrandom/2025/scripts/awk/wrap_json_object.awk"

# Test Case 1: Basic input
INPUT='"foo":"2","bar":"1"'
ACTUAL_OUTPUT=$(echo -e "$INPUT" | awk -f "$AWK_SCRIPT")

# Validate with jq
if echo "$ACTUAL_OUTPUT" | jq . > /dev/null 2>&1; then
  echo "Test Case 1 Passed: Basic input (jq validation)"
else
  echo "Test Case 1 Failed: Basic input (jq validation)"
  echo "Actual:   $ACTUAL_OUTPUT"
  exit 1
fi

# Test Case 2: Empty input
INPUT=""
ACTUAL_OUTPUT=$(echo -e "$INPUT" | awk -f "$AWK_SCRIPT")

# Validate with jq
if echo "$ACTUAL_OUTPUT" | jq . > /dev/null 2>&1; then
  echo "Test Case 2 Passed: Empty input (jq validation)"
else
  echo "Test Case 2 Failed: Empty input (jq validation)"
  echo "Actual:   $ACTUAL_OUTPUT"
  exit 1
fi

echo "All tests for wrap_json_object.awk passed."
