#!/usr/bin/env bash

set -euo pipefail

# The 'out' variable is provided by Nix.
# NIX_FILE_PATH, NIX_FILE_CONTENT, and lockFile are expected to be provided by Nix.

out="${out:-/tmp/nix-build-output}" # Default for shellcheck, actual value from Nix
NIX_FILE_PATH="${NIX_FILE_PATH:-/tmp/flake.nix}"
NIX_FILE_CONTENT="${NIX_FILE_CONTENT:-{ }\n}"
lockFile="${lockFile:-/tmp/flake.lock}"

mkdir -p "$out"

# Use the centralized bag-of-words generator script
BAG_OF_WORDS=$(nix build --no-link --print-out-paths \
"github:meta-introspector/streamofrandom/2025/flakes/bag-of-words-generator#lib.generateBagOfWords" \
--argstr flakePath "$NIX_FILE_PATH" \
| xargs cat)

echo "DEBUG: NIX_FILE_PATH = $NIX_FILE_PATH"
echo "DEBUG: lockFile = $lockFile"
echo "DEBUG: BAG_OF_WORDS = $BAG_OF_WORDS"

jq -n --arg nixFilePath "$NIX_FILE_PATH" --arg lockFilePath "$lockFile" --argjson bagOfWords "$BAG_OF_WORDS" -f /data/data/com.termux.nix/files/home/pick-up-nix2/source/github/meta-introspector/streamofrandom/2025/scripts/jq/generate_lock_file_info.jq > "$out/lock-file-info.json"
