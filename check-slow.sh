#!/usr/bin/env bash

#set -euo pipefail
set -x

TEST_FLAKE_DIR="/data/data/com.termux.nix/files/home/pick-up-nix2/source/github/meta-introspector/streamofrandom/2025/tests/test-package-bag-of-words"

echo "Attempting to build the test-package-bag-of-words flake..."

if nix build -vvvv "$TEST_FLAKE_DIR"#default; then
  echo "Build successful!"
  echo "You can view the generated bag-of-words.json at: ./result/bag-of-words.json (relative to $TEST_FLAKE_DIR)"
else
  echo "Build failed. Please check the output above for errors."
  echo "You can try running 'nix build --show-trace $TEST_FLAKE_DIR#default' for more detailed error messages."
fi
