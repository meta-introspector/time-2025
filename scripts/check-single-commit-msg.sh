#!/usr/bin/env bash

# This script checks a single commit message file against the Nix commit message checker.
# It returns 0 for valid and 1 for invalid.

set -euo pipefail

COMMIT_MSG_FILE="$1"
CHECKER_NIX="./commit-msg-check.nix" # Relative path from the main script's execution context

# Execute the Nix checker with the provided commit message file
# We use nix-instantiate --eval to get the output, as nix build --no-out-link is not supported
# and we want to see the error message directly.
# The checker itself will exit with 0 for valid, 1 for invalid.
if nix-instantiate --eval "${CHECKER_NIX}" --argstr commitMsgFile "${COMMIT_MSG_FILE}" > /dev/null 2>&1; then
  exit 0 # Passed
else
  # Print the full error message from the checker
  nix-instantiate --eval "${CHECKER_NIX}" --argstr commitMsgFile "${COMMIT_MSG_FILE}" 2>&1 || true
  exit 1 # Failed
fi
