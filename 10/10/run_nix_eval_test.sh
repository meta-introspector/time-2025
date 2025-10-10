#!/usr/bin/env bash

INPUT_PATH="$1"

if [ -z "$INPUT_PATH" ]; then
  echo "Usage: $0 <INPUT_PATH>"
  exit 1
fi

echo "Running: nix eval --raw -f $INPUT_PATH/get-nix-file-list.nix"
nix eval --json -f "$INPUT_PATH/get-nix-file-list.nix"