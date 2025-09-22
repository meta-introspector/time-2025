#!/usr/bin/env bash

set -euo pipefail

FLAKE_ATTR_PATH="./nix-llm-context#packages.aarch64-linux.monsterGroupLlmContext"
REPO_URL="https://github.com/meta-introspector/crq-binstore.git"

echo "Calling publish_nix_artifact_to_git.sh with parameters..."
scripts/publish_nix_artifact_to_git.sh "${FLAKE_ATTR_PATH}" "${REPO_URL}"

echo "Publishing monster group NAR complete."
