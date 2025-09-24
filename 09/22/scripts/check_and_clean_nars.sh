#!/usr/bin/env bash

set -euo pipefail

CRQ_BINSTORE_DIR="/data/data/com.termux.nix/files/home/pick-up-nix2/source/github/meta-introspector/streamofrandom/2025/09/crq-binstore"
NIX_NAR_CLI="/data/data/com.termux.nix/files/home/nix/vendor/nix/nix-nar-rs/cli"

for nar_file in "$CRQ_BINSTORE_DIR"/*.nar; do
  if [ -f "$nar_file" ]; then
    echo "Checking NAR file: $nar_file"
    if ! "$NIX_NAR_CLI" ls "$nar_file" > /dev/null 2>&1; then
      echo "Invalid NAR file detected: $nar_file. Deleting..."
      rm "$nar_file"
    else
      echo "NAR file is valid: $nar_file"
    fi
  fi
done

echo "NAR file check and cleanup complete."
