#!/usr/bin/env bash
set -euo pipefail

NIXPKGS_PATH="$1"
CRQ_CHECK_LIB_PATH="$2"
COMMIT_MSG_FILE="$3"

# Ensure jq is available
if ! command -v jq &> /dev/null
then
    echo "Error: jq command not found. Please install jq." >&2
    exit 1
fi

NIX_OUTPUT=$(nix eval --json --arg pkgs "$NIXPKGS_PATH" --arg crqCheckLib "$CRQ_CHECK_LIB_PATH" --argstr commitMsgFile "$COMMIT_MSG_FILE" --expr 'let pkgs = import pkgs {}; in import crqCheckLib { inherit pkgs; commitMsgFile = commitMsgFile; }')

SUCCESS=$(echo "$NIX_OUTPUT" | jq -r '.success')
MESSAGE=$(echo "$NIX_OUTPUT" | jq -r '.message')

if [ "$SUCCESS" = "false" ]; then
  echo "$MESSAGE" >&2
  exit 1
else
  exit 0
fi