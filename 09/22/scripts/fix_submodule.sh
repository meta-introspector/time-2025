#!/usr/bin/env bash

set -e

if [ -z "$1" ]; then
  echo "Usage: $0 <submodule_path>"
  exit 1
fi

SUBMODULE_PATH="$1"
CRQ_NUMBER="016"
COMMIT_DESCRIPTION="Standardize flake.nix from template"


echo "--- Running nixify on $SUBMODULE_PATH ---"
./scripts/nixify.sh "$SUBMODULE_PATH" --apply

echo "--- Committing and pushing changes for $SUBMODULE_PATH ---"
./scripts/commit_and_push_flakes.sh "$SUBMODULE_PATH"

echo "--- Submodule fix complete for $SUBMODULE_PATH ---"
