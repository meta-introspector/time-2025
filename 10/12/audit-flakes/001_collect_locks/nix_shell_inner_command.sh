#!/usr/bin/env bash

set -euo pipefail

# These variables are expected to be exported by the calling script (run_flake_sh_test_env.sh)
# when running inside nix-shell.

# The 'out' variable is provided by Nix.
# NIX_FILE_PATH, NIX_FILE_CONTENT, and lockFile are expected to be provided by Nix.
out="${out:-/tmp/nix-build-output}" # Default for shellcheck, actual value from Nix
NIX_FILE_PATH="${NIX_FILE_PATH:-/tmp/flake.nix}"
lockFile="${lockFile:-/tmp/flake.lock}"
BAG_OF_WORDS_GENERATOR_PATH="${BAG_OF_WORDS_GENERATOR_PATH:-/tmp/bag-of-words-generator}"
pkgs="${pkgs:-/tmp/pkgs}" # Default for shellcheck
lib="${lib:-/tmp/lib}"   # Default for shellcheck

mkdir -p "$out"

# Calculate bag of words
echo "DEBUG: BAG_OF_WORDS_GENERATOR_PATH = $BAG_OF_WORDS_GENERATOR_PATH"
SYSTEM=$(nix eval --raw --impure --expr 'builtins.currentSystem')
BAG_OF_WORDS_JSON_FILE=$(mktemp)

BAG_OF_WORDS_OUTPUT_PATH=$(nix build --no-link --print-out-paths \
  --extra-experimental-features 'nix-command flakes' \
  "$BAG_OF_WORDS_GENERATOR_PATH#lib.${SYSTEM}.generateBagOfWords" \
  --argstr flakePath "$NIX_FILE_PATH")

cat "$BAG_OF_WORDS_OUTPUT_PATH/report.json" > "$BAG_OF_WORDS_JSON_FILE"

echo "DEBUG: NIX_FILE_PATH = $NIX_FILE_PATH"
echo "DEBUG: lockFile = $lockFile"
echo "DEBUG: BAG_OF_WORDS_JSON_FILE = $BAG_OF_WORDS_JSON_FILE"

jq -n \
                  --arg nixFilePath "$NIX_FILE_PATH" \
                  --arg lockFilePath "$lockFile" \
                  --argjson bagOfWords "$(cat "$BAG_OF_WORDS_JSON_FILE")" \
                  -f /data/data/com.termux.nix/files/home/pick-up-nix2/source/github/meta-introspector/streamofrandom/2025/scripts/jq/generate_lock_file_info.jq > "$out/lock-file-info.json"

rm "$BAG_OF_WORDS_JSON_FILE"

# Output the content of the generated JSON for inspection
cat "$out/lock-file-info.json"
