#!/usr/bin/env bash

set -euo pipefail

# List of primes from the order of the Monster Group up to 71
PRIMES=(2 3 5 7 11 13 17 19 23 29 31 41 47 59 71)

REPO_URL="https://github.com/meta-introspector/crq-binstore.git"

for prime in "${PRIMES[@]}"; do
  echo "Building and exporting zos sequence for prime: $prime"
  FLAKE_ATTR_PATH="./nix-llm-context#packages.zosSequence.${prime}"
  
  scripts/publish_nix_artifact_to_git.sh "${FLAKE_ATTR_PATH}" "${REPO_URL}"
  echo "----------------------------------------------------"
done

echo "All zos sequence NARs built and published."
