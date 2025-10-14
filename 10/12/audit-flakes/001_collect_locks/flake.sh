#!/usr/bin/env bash

# The 'out' variable is provided by Nix.
# NIX_FILE_PATH, NIX_FILE_CONTENT, and lockFile are expected to be provided by Nix.
out="${out:-/tmp/nix-build-output}" # Default for shellcheck, actual value from Nix
NIX_FILE_PATH="${NIX_FILE_PATH:-/tmp/flake.nix}"
NIX_FILE_CONTENT="${NIX_FILE_CONTENT:-{ }\n}"
lockFile="${lockFile:-/tmp/flake.lock}"

mkdir -p "$out"

# Calculate bag of words
echo "DEBUG: BAG_OF_WORDS_GENERATOR_PATH = $BAG_OF_WORDS_GENERATOR_PATH"
SYSTEM=$(nix eval --raw --impure --expr 'builtins.currentSystem')
BAG_OF_WORDS=$(nix eval --raw --impure \
  --extra-experimental-features 'nix-command flakes' \
  "$BAG_OF_WORDS_GENERATOR_PATH#lib.${SYSTEM}.generateBagOfWords \"$NIX_FILE_PATH\"" \
  | xargs -I {} cat {}/report.json)

echo "DEBUG: NIX_FILE_PATH = $NIX_FILE_PATH"
echo "DEBUG: lockFile = $lockFile"
echo "DEBUG: BAG_OF_WORDS = $BAG_OF_WORDS"

jq -n \
                  --arg nixFilePath "$NIX_FILE_PATH" \
                  --arg lockFilePath "$lockFile" \
                  --argjson bagOfWords "$BAG_OF_WORDS" \
                  -f /data/data/com.termux.nix/files/home/pick-up-nix2/source/github/meta-introspector/streamofrandom/2025/scripts/jq/generate_lock_file_info.jq > "$out/lock-file-info.json"
