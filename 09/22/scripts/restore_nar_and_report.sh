#!/usr/bin/env bash

set -euo pipefail

NAR_FILE_PATH="$1"
TARGET_PATH="$2"
TEMP_NAR_INPUT="/tmp/gemini_nar_temp.nar"
NIX_STORE_EXECUTABLE="/nix/store/0x7s63gjcvybs6fgdq9p6z5l8svcxaav-nix-on-droid-path/bin/nix-store"

cleanup() {
  echo "Cleaning up temporary NAR file..."
  rm -f "$TEMP_NAR_INPUT"
  echo "Cleaning up restored NAR content..."
  rm -rf "$TARGET_PATH"
}

trap cleanup EXIT

if [ -z "$NAR_FILE_PATH" ] || [ -z "$TARGET_PATH" ]; then
  echo "Error: Usage: $0 <absolute_path_to_nar_file> <target_restore_path>"
  exit 1
fi

if [ ! -f "$NAR_FILE_PATH" ]; then
  echo "Error: NAR file not found: $NAR_FILE_PATH"
  exit 1
fi

if [ -e "$TARGET_PATH" ]; then
  echo "Error: Target path already exists: $TARGET_PATH. Please remove it first."
  exit 1
fi

echo "Copying NAR file to temporary location: $TEMP_NAR_INPUT"
cp "$NAR_FILE_PATH" "$TEMP_NAR_INPUT"

echo "Restoring NAR file to Nix store..."
"$NIX_STORE_EXECUTABLE" --restore "$TARGET_PATH" < "$TEMP_NAR_INPUT"

echo "NAR restored to: $TARGET_PATH"

echo "--- NAR Content Report ---"
"$NIX_STORE_EXECUTABLE" -q --tree "$TARGET_PATH"

echo "--- End of NAR Content Report ---"

echo "NAR inspection complete."