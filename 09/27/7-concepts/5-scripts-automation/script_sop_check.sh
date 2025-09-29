#!/usr/bin/env bash

set -e
set -o pipefail

# This script checks if new or modified executable scripts have a corresponding SOP document.

PROJECT_ROOT=$(git rev-parse --show-toplevel)

for FILE in "$@"; do
  if [[ "$FILE" =~ \.(sh|py|rs|nix)$ && -x "$FILE" ]]; then # Check for executable scripts
    SCRIPT_NAME=$(basename "$FILE")
    SOP_FILE="${PROJECT_ROOT}/docs/sops/${SCRIPT_NAME%.*}.md" # Assuming SOP name matches script name without extension
    if [ ! -f "$SOP_FILE" ]; then
      echo "Warning: Script $FILE is not documented with a corresponding SOP at $SOP_FILE."
      # exit 1 # Uncomment to make this a blocking check
    fi
  fi
done
