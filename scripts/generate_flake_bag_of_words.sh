#!/usr/bin/env bash

set -euo pipefail

if [ -z "$1" ]; then
  echo "Usage: $0 <path_to_flake.nix>"
  exit 1
fi

FLAKE_NIX_PATH="$1"
NIX_FILE_CONTENT="$(cat "$FLAKE_NIX_PATH")"

# Process the content to generate bag of words
STEP1=$(echo -n "$NIX_FILE_CONTENT" | tr '[:upper:]' '[:lower:]')
STEP2=$(echo -n "$STEP1" | grep -oE '\w+')
STEP3=$(echo -n "$STEP2" | sort)
STEP4=$(echo -n "$STEP3" | uniq -c)
STEP5=$(echo -n "$STEP4" | awk 'NF {print "\"" $2 "\":" $1}')
STEP6=$(echo -n "$STEP5" | paste -sd, -)

BAG_OF_WORDS=$(echo -n "$STEP6" | awk -v OFS="" 'BEGIN{print "{"}{print $0}END{print "}"}')

echo "$BAG_OF_WORDS"
