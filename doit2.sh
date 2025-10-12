#!/usr/bin/env bash
set -euo pipefail

echo "Building the grand-vision-test flake..."
nix build 10/12/proof/vendor/rnix-parser/tests/grand-vision-test
echo "Build complete. Output in result/rnix-flake-ast.json"
