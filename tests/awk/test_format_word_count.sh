#!/usr/bin/env bash

set -euo pipefail

AWK_SCRIPT="/data/data/com.termux.nix/files/home/pick-up-nix2/source/github/meta-introspector/streamofrandom/2025/scripts/awk/format_word_count.awk"

# Test Case 1: Basic input
INPUT="      2 foo\n      1 bar"
ACTUAL_OUTPUT=$(echo -e "$INPUT" | awk -f "$AWK_SCRIPT")

if [[ -n "$ACTUAL_OUTPUT" && "$ACTUAL_OUTPUT" == *"\"foo\":\"2\""* && "$ACTUAL_OUTPUT" == *"\"bar\":\"1\""* ]]; then
  echo "Test Case 1 Passed: Basic input"
else
  echo "Test Case 1 Failed: Basic input"
  echo "Actual:   $ACTUAL_OUTPUT"
  exit 1
fi

# Test Case 2: Empty input
INPUT=""
ACTUAL_OUTPUT=$(echo -e "$INPUT" | awk -f "$AWK_SCRIPT")

if [[ "$ACTUAL_OUTPUT" == "\"\":\"\"" ]]; then
  echo "Test Case 2 Passed: Empty input"
else
  echo "Test Case 2 Failed: Empty input"
  echo "Actual:   $ACTUAL_OUTPUT"
  exit 1
fi

echo "All tests for format_word_count.awk passed."
