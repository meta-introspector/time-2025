#!/usr/bin/env bash
set -euo pipefail

system="aarch64-linux" # Dummy definition for shellcheck


echo "Testing verifyQuasifiber..."
verification_result_derivation=$(nix eval --raw --expr "(import ./verify-quasifiber-eval.nix) { \
  narSimilaritySearchFlake = builtins.getFlake (toString ../../nar-similarity-search); \
  system = \"$system\"; \
  dummyResults = \"dummy-results\"; \
}")
verification_result=$(cat "$verification_result_derivation")
if [[ "$verification_result" != "Verification complete: Results form a conceptual quasifiber." ]]; then
  echo "Error: Quasifiber verification failed." >&2
  exit 1
fi