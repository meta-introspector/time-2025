#!/usr/bin/env bash

set -euo pipefail

# This script publishes a generic knowledge node NAR to a Git repository.
# It acts as a wrapper for the core 'publish_nix_artifact_to_git.sh' script.

FLAKE_ATTR_PATH="$1"
REPO_URL="$2"

if [[ -z "$FLAKE_ATTR_PATH" || -z "$REPO_URL" ]]; then
  echo "Usage: $0 <FLAKE_ATTR_PATH> <REPO_URL>"
  echo "Example: $0 .#packages.aarch64-linux.knowledge-article-monster-group https://github.com/meta-introspector/crq-binstore.git"
  exit 1
fi

# Assuming publish_nix_artifact_to_git.sh is in the same 'scripts' directory
PUBLISH_CORE_SCRIPT="$(dirname "${BASH_SOURCE[0]}")/publish_nix_artifact_to_git.sh"

if [[ ! -f "$PUBLISH_CORE_SCRIPT" ]]; then
  echo "Error: Core publishing script not found at '$PUBLISH_CORE_SCRIPT'."
  echo "Please ensure 'publish_nix_artifact_to_git.sh' exists in the 'scripts/' directory."
  exit 1
fi

echo "Publishing knowledge node NAR from attribute path: $FLAKE_ATTR_PATH to $REPO_URL"

"$PUBLISH_CORE_SCRIPT" "$FLAKE_ATTR_PATH" "$REPO_URL"

echo "Knowledge node NAR publishing process initiated."
