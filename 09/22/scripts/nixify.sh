#!/usr/bin/env bash

set -e

if [ -z "$1" ]; then
  echo "Usage: $0 <submodule_path> [--apply]"
  exit 1
fi

SUBMODULE_PATH="$1"
APPLY_CHANGES=false
if [ "$2" == "--apply" ]; then
  APPLY_CHANGES=true
fi

FLAKE_FILE="$SUBMODULE_PATH/flake.nix"
TEMPLATE_FILE="scripts/flake.template"

if [ ! -f "$TEMPLATE_FILE" ]; then
  echo "Error: Template file not found at $TEMPLATE_FILE"
  exit 1
fi

FLAKE_TEMPLATE=$(cat "$TEMPLATE_FILE")

if [ ! -f "$FLAKE_FILE" ]; then
  if [ "$APPLY_CHANGES" = true ]; then
    echo "Creating flake.nix in $SUBMODULE_PATH."
    echo "$FLAKE_TEMPLATE" > "$FLAKE_FILE"
    echo "flake.nix created successfully."
  else
    echo "[DRY RUN] flake.nix not found in $SUBMODULE_PATH. It would be created with the following content:"
    echo "---"
    echo "$FLAKE_TEMPLATE"
    echo "---"
    echo "Run with --apply to create the file."
  fi
else
  TEMP_TEMPLATE_FILE=$(mktemp)
  echo "$FLAKE_TEMPLATE" > "$TEMP_TEMPLATE_FILE"
  
  if diff -u "$FLAKE_FILE" "$TEMP_TEMPLATE_FILE" >/dev/null; then
    echo "flake.nix in $SUBMODULE_PATH is already up to date with the template."
  else
    if [ "$APPLY_CHANGES" = true ]; then
      echo "Backing up existing flake.nix to $FLAKE_FILE.bak"
      mv "$FLAKE_FILE" "$FLAKE_FILE.bak"
      echo "Creating new flake.nix from template."
      echo "$FLAKE_TEMPLATE" > "$FLAKE_FILE"
      echo "flake.nix has been updated."
    else
      echo "[DRY RUN] flake.nix in $SUBMODULE_PATH differs from the template."
      echo "Showing diff:"
      diff -u "$FLAKE_FILE" "$TEMP_TEMPLATE_FILE" || true
      echo "Run with --apply to create a backup and overwrite the file."
    fi
  fi
  
  rm "$TEMP_TEMPLATE_FILE"
fi