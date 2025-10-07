#!/usr/bin/env bash
set -euo pipefail

# Create the output directory
mkdir -p "$1/foo"

# Create the test.nix file
echo 'bar' > "$1/foo/test.nix"
