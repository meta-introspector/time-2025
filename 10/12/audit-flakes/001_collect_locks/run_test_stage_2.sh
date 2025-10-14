#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR=$(dirname "$(readlink -f "$0")")

echo "Evaluating test-stage-2.nix..."

nix eval --raw --impure --extra-experimental-features 'nix-command flakes' -f "$SCRIPT_DIR/test-stage-2.nix"

echo "Evaluation completed."
