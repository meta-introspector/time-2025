#!/usr/bin/env bash
set -euo pipefail
keyword="$1"
filesList="$2"
out="$3"

echo "Searching for '${keyword}' in files from ${filesList}..."
found_files=()

while IFS= read -r file; do
  if [ -f "$file" ] && grep -q -w "$keyword" "$file"; then
    found_files+=("$file")
  fi
done < "$filesList"

if [ ${#found_files[@]} -gt 0 ]; then
  echo "Found '${keyword}' in the following files:" >&2
  for file in "${found_files[@]}"; do
    echo "$file" >&2
    grep -w -C 3 "$keyword" "$file" >&2 # Print 3 lines of context
    echo "---" >&2
  done
  echo "Search results saved to $out"
  printf "%s\n" "${found_files[@]}" > "$out"
else
  echo "No occurrences of '${keyword}' found." >&2
  echo "(empty)" > "$out"
fi
