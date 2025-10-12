#!/usr/bin/env bash
set -euo pipefail
searchNumber="$1"
searchPatternsJson="$2"
projectRoot="$3"
out="$4"

echo "Searching for '${searchNumber}' in files matching ${searchPatternsJson}..."

# Convert glob patterns to regex
patterns_regex=$(echo "$searchPatternsJson" | jq -r '.[]' | sed 's/\./\\./g; s/\*/.*/g; s/\?/./g; s/\*\*\///.*/g' | paste -sd '|' -)
found_files=()

# Find all files within projectRoot and filter by regex pattern, then check content
find "$projectRoot" -type f -print0 | while IFS= read -r -d $'\0' file; do
  if echo "$file" | grep -qE "$patterns_regex"; then # Filter by path pattern
    if grep -q -w "$searchNumber" "$file"; then # Check content
      found_files+=("$file")
    fi
  fi
done

if [ ${#found_files[@]} -gt 0 ]; then
  echo "Found '${searchNumber}' in the following files:" >&2
  for file in "${found_files[@]}"; do
    echo "$file" >&2
    grep -w -C 3 "$searchNumber" "$file" >&2 # Print 3 lines of context
    echo "---" >&2
  done
  echo "Search results saved to $out"
  printf "%s\n" "${found_files[@]}" > "$out"
else
  echo "No occurrences of '${searchNumber}' found." >&2
  echo "(empty)" > "$out"
fi
