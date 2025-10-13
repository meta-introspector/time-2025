#!/usr/bin/env bash

# This script runs the flake audit pipeline and outputs the final report.

set -euo pipefail

# The path to the audit flake
AUDIT_FLAKE_PATH="./10/12/audit-flakes"

# Build the final report
echo "Building the flake audit report..."
nix build --no-write-lock-file --recreate-lock-file "$AUDIT_FLAKE_PATH#default"

# The result is a symlink in the current directory.
# The report is in the output path.
RESULT_PATH="$(readlink -f ./result)"

echo "Audit report built successfully."
echo "Report is available at: $RESULT_PATH/all-audit-chunks.json"
