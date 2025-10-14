#!/usr/bin/env bash

set -euo pipefail

export NIX_FILE_CONTENT="{ }\n"
export NIX_FILE_PATH="/nix/store/x7lbsp5xzazsn28chvj6yp4w15x7vhyb-source/flake.nix"
export lockFile="/nix/store/x7lbsp5xzazsn28chvj6yp4w15x7vhyb-source/flake.lock"
export out="/data/data/com.termux.nix/files/home/pick-up-nix2/source/github/meta-introspector/streamofrandom/2025/tmp/test_lock_file_0_build"

mkdir -p "$out"

# The actual buildCommand, unescaped for direct execution
BUILD_COMMAND="mkdir -p $out"

# Calculate bag of words
BAG_OF_WORDS=$(nix eval --raw --impure \
"github:meta-introspector/time-2025?ref=feature/aimyc-002-sample-extraction&dir=flakes/bag-of-words-generator#lib.generateBagOfWords \"$NIX_FILE_PATH\"" \
| xargs -I {} cat {}/report.json)

jq -n \
  --arg nixFilePath "$NIX_FILE_PATH" \
  --arg lockFilePath "$lockFile" \
  --argjson bagOfWords "$BAG_OF_WORDS" \
  -f ../../../../scripts/jq/generate_lock_file_info.jq > "$out/lock-file-info.json"

# Execute the build command
eval "$BUILD_COMMAND"

echo "Build command executed. Check $out/lock-file-info.json for output."

