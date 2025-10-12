#!/usr/bin/env bash
set -euo pipefail

echo "Finding .nix files with 'dir=source/github/meta-introspector/streamofrandom/2025' in url attributes..."
FILES_TO_FIX=$(grep -r -l 'url = ".*dir=source/github/meta-introspector/streamofrandom/2025"' . --include=\*.nix)

if [ -z "$FILES_TO_FIX" ]; then
  echo "No files found to fix."
  exit 0
fi

echo "Found files: $FILES_TO_FIX"
echo "Applying sed replacement..."

for file in $FILES_TO_FIX; do
  echo "Fixing $file"
  sed -i 's|dir=source/github/meta-introspector/streamofrandom/2025|dir=|g' "$file"
done

echo "Fixing complete."