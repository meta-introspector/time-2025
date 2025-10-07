#!/usr/bin/env bash
set -euo pipefail

PROMPT_STRING="$1" # The prompt will be passed as the first argument to the script

echo "🚀 Running gemini-cli with prompt: $PROMPT_STRING"

# Create a temporary Nix file for the prompt string
TEMP_PROMPT_NIX=$(mktemp /tmp/gemini-prompt-XXXXXX.nix)
echo "$PROMPT_STRING" > "$TEMP_PROMPT_NIX"

nix build \
  --impure \
  --extra-experimental-features "nix-command flakes impure-derivations" \
  /data/data/com.termux.nix/files/home/pick-up-nix2/source/github/meta-introspector/streamofrandom/2025/10/04/gemini-prompt-flake#packages.gemini-prompt-derivation \
  --override-input promptArg "path:$TEMP_PROMPT_NIX"

# Clean up the temporary file
rm "$TEMP_PROMPT_NIX"
