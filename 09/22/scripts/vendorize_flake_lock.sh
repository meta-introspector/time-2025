#!/usr/bin/env bash

set -euo pipefail

PROJECT_ROOT="$(dirname "$(dirname "$(realpath "$0")")")"
source "${PROJECT_ROOT}/lib/lib_github_fork.sh"

# This script vendorizes the dependencies in the flake.lock file.

# TODO: Replace with a real token
export GITHUB_TOKEN="your-github-token"

# Read the flake.lock file
FLAKE_LOCK=$(cat flake.lock)

# Identify the external dependencies
EXTERNAL_DEPS=$(echo "$FLAKE_LOCK" | jq -r '.nodes[] | select(.locked.type == "github" and .locked.owner != "meta-introspector") | .original.owner + "/" + .original.repo')

# Fork the external dependencies
for repo in $EXTERNAL_DEPS; do
  echo "Forking $repo..."
  lib_github_fork_repo "$repo" "meta-introspector" "$(basename $repo)"
done

# Update the flake.nix file
# TODO: This part is tricky and may require manual intervention.
# We need to identify which inputs in the flake.nix correspond to the
# dependencies we just forked and update their URLs.

# Update the flake.lock file
for repo in $EXTERNAL_DEPS; do
  echo "Updating flake.lock for $(basename $repo)..."
  nix flake lock --update-input "$(basename $repo)"
done
