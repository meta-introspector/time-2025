#!/usr/bin/env bash

set -euo pipefail

rm -rf ./test_output

for article in /data/data/com.termux.nix/files/home/pick-up-nix2/source/github/meta-introspector/streamofrandom/2025/09/22/wikipedia_cache/*; do
  if [ -f "$article" ]; then
    article_name=$(basename "$article")
    echo "Packaging $article_name..."
    /data/data/com.termux.nix/files/home/pick-up-nix2/source/github/meta-introspector/streamofrandom/2025/09/22/scripts/test_packaging.sh "$article_name"
  fi
done
