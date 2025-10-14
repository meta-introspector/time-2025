#!/usr/bin/env bash

set -euo pipefail

# Set environment variables as they would be in the Nix build environment
export NIX_FILE_PATH="/data/data/com.termux.nix/files/home/pick-up-nix2/source/github/meta-introspector/streamofrandom/2025/flake.nix"
export lockFile="/data/data/com.termux.nix/files/home/pick-up-nix2/source/github/meta-introspector/streamofrandom/2025/flake.lock"
NIX_FILE_CONTENT="$(cat "$NIX_FILE_PATH")"
export NIX_FILE_CONTENT
export out="/data/data/com.termux.nix/files/home/pick-up-nix2/source/github/meta-introspector/streamofrandom/2025/tmp/test_flake_sh_output"

mkdir -p "$out"

echo "NIX_FILE_CONTENT: '$NIX_FILE_CONTENT'"

STEP1=$(echo -n "$NIX_FILE_CONTENT" | tr '[:upper:]' '[:lower:]')
echo "STEP1 (tr): '$STEP1'"

STEP2=$(echo -n "$STEP1" | grep -oE '\w+')
echo "STEP2 (grep): '$STEP2'"

STEP3=$(echo -n "$STEP2" | sort)
echo "STEP3 (sort): '$STEP3'"

STEP4=$(echo -n "$STEP3" | uniq -c)
echo "STEP4 (uniq -c): '$STEP4'"

STEP5=$(echo -n "$STEP4" | awk 'NF {print "\"" $2 "\":" $1}')
echo "STEP5 (awk): '$STEP5'"

STEP6=$(echo -n "$STEP5" | paste -sd, -)
echo "STEP6 (paste): '$STEP6'"

BAG_OF_WORDS=$(echo -n "$STEP6" | awk -v OFS="" 'BEGIN{print "{"}{print $0}END{print "}"}'
)
echo "BAG_OF_WORDS (final): '$BAG_OF_WORDS'"

echo "$BAG_OF_WORDS" > "$out/lock-file-info.json"
echo "flake.sh executed. Check $out/lock-file-info.json for output."
