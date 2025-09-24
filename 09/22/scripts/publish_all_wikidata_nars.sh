#!/usr/bin/env bash

set -euo pipefail

# Source the lib_exec.sh library for execute_cmd
source "/data/data/com.termux.nix/files/home/pick-up-nix2/source/github/meta-introspector/streamofrandom/2025/09/22/lib/lib_exec.sh"

# Path to the publish script
PUBLISH_SCRIPT="/data/data/com.termux.nix/files/home/pick-up-nix2/source/github/meta-introspector/streamofrandom/2025/09/22/scripts/publish_nix_artifact_to_git.sh"

# Target repository URL
REPO_URL="https://github.com/meta-introspector/crq-binstore.git"

# Get a list of all dynamically generated Wikidata packages
# We assume the packages are named like <articleName>-wikidata
# and are under the 'packages' attribute of the flake.

# This command will list all packages in the flake and filter for wikidata packages
# It will output something like: packages.aarch64-linux.someArticleWikidata
# We need to extract 'someArticleWikidata'

# Temporarily disable pipefail for the nix eval command as it might fail if no packages are found
set +o pipefail
CURRENT_SYSTEM=$(nix-instantiate --eval --expr 'builtins.currentSystem' --json | jq -r .)
PACKAGE_ATTRS=$(cat flake22.json | jq -r --arg system "$CURRENT_SYSTEM" '.packages[$system] | to_entries[] | select(.value.name | endswith("-wikidata")) | .key')
set -o pipefail

if [ -z "$PACKAGE_ATTRS" ]; then
  echo "No Wikidata packages found in flake.nix. Exiting."
  exit 0
fi

for attr in $PACKAGE_ATTRS; do
  FLAKE_ATTR_PATH=".#${attr}"
  ARTICLE_NAME=$(nix eval --raw "${FLAKE_ATTR_PATH}.passthru.wikipedia")
  execute_cmd echo "Publishing $ARTICLE_NAME ($FLAKE_ATTR_PATH)..."
  "$PUBLISH_SCRIPT" "$FLAKE_ATTR_PATH" "$REPO_URL"
done

echo "All Wikidata NARs published."
