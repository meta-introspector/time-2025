#!/usr/bin/env bash

# Dummy values for testing
NIX_FILE_PATH="/nix/store/dummy-source/flake.nix"
LOCK_FILE_PATH="/nix/store/dummy-source/flake.lock"
NIX_FILE_CONTENT="{\"description\": \"dummy flake\"}" # A simple JSON string
GENERATE_LOCK_INFO_JQ="/nix/store/1852hqlv946lgsmq2dj2jv2y0r0iddzi-generate-lock-info-jq" # This path needs to be valid in your Nix store
OUT_DIR="./test_output"

mkdir -p "$OUT_DIR"

# The jq command from the buildCommand
jq -n \
  --arg nixFilePath "$NIX_FILE_PATH" \
  --arg lockFilePath "$LOCK_FILE_PATH" \
  --argjson nixFileContent "$(jq -Rs . <<< "$NIX_FILE_CONTENT")" \
  -f "$GENERATE_LOCK_INFO_JQ" | jq . > "$OUT_DIR/lock-file-info.json"

echo "Output written to $OUT_DIR/lock-file-info.json"
cat "$OUT_DIR/lock-file-info.json"
