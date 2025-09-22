#!/usr/bin/env bash

set -euo pipefail

echo "--- Running nix develop and checking rustc version ---"
nix develop --command rustc --version

echo ""
echo "--- Nix environment checks complete ---"