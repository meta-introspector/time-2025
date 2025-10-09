#!/usr/bin/env bash
set -euo pipefail

# --- Configuration ---
SEARCH_KEYWORD=""
LIMIT_RESULTS=""
LIST_IMPORTS=false
SUMMARY_REPORT=false
GROUP_BY_URL=false
FLAKE_ROOT="/data/data/com.termux.nix/files/home/pick-up-nix2/source/github/meta-introspector/streamofrandom/2025/"
NIX_FILE_ANALYZER_SCRIPT="/data/data/com.termux.nix/files/home/pick-up-nix2/source/github/meta-introspector/streamofrandom/2025/scripts/nix_file_analyzer.sh"

# --- Functions ---
usage() {
  echo "Usage: $0 --search <keyword> [--limit <number>] [--list-imports] [--summary [--group-by url]]"
  echo "  --search <keyword> : Required. The keyword to search for in Nix files."
  echo "  --limit <number>   : Optional. The maximum number of matching lines to show per file. Defaults to all."
  echo "  --list-imports     : Optional. For each matching file, list its import statements."
  echo "  --summary          : Optional. Provide a consolidated summary report instead of per-file details."
  echo "  --group-by url     : Optional. Used with --summary. Groups the summary by unique URLs found."
  exit 1
}

# --- Argument Parsing ---
while [[ "$#" -gt 0 ]]; do
  case "$1" in
    --search=*) SEARCH_KEYWORD="${1#*=}" ;;
    --search) SEARCH_KEYWORD="$2"; shift ;;
    --limit=*) LIMIT_RESULTS="${1#*=}" ;;
    --limit) LIMIT_RESULTS="$2"; shift ;;
    --list-imports) LIST_IMPORTS=true ;;
    --summary) SUMMARY_REPORT=true ;;
    --group-by)
      if [ "$2" == "url" ]; then
        GROUP_BY_URL=true
        shift
      else
        echo "Error: Invalid value for --group-by. Only 'url' is supported."
        usage
      fi
      ;;
    -h|--help) usage ;;
    *) echo "Unknown parameter passed: $1"; usage ;;
  esac
  shift
done

# --- Validation ---
if [ -z "$SEARCH_KEYWORD" ]; then
  echo "Error: --search keyword is required."
  usage
fi

if "$GROUP_BY_URL" && ! "$SUMMARY_REPORT"; then
  echo "Error: --group-by url can only be used with --summary."
  usage
fi

# --- Main Logic ---
echo "Searching for '$SEARCH_KEYWORD' in Nix files (limit per file: ${LIMIT_RESULTS:-'none'})..."
echo "--------------------------------------------------------------------------------"

# Find all .nix files
NIX_FILES=()
while IFS= read -r -d '' file; do
  NIX_FILES+=("$file")
done < <(find "$FLAKE_ROOT" -type f -name "*.nix" -print0)

if [ ${#NIX_FILES[@]} -eq 0 ]; then
  echo "No .nix files found in $FLAKE_ROOT"
  exit 0
fi

# Data structures for summary report
declare -A all_imports
declare -A all_file_paths
declare -A all_generic_urls
declare -A all_flake_input_urls
#declare -A file_matches_count # Count of keyword matches per file
declare -A url_to_files # For --group-by url

MATCHING_FILES_COUNT=0
TOTAL_KEYWORD_MATCHES=0

for nix_file in "${NIX_FILES[@]}"; do
  MATCHES=$(grep -nE "$SEARCH_KEYWORD" "$nix_file" || true)
  if [ -n "$MATCHES" ]; then
    MATCHING_FILES_COUNT=$((MATCHING_FILES_COUNT + 1))
    FILE_KEYWORD_MATCH_COUNT=$(echo "$MATCHES" | wc -l)
    TOTAL_KEYWORD_MATCHES=$((TOTAL_KEYWORD_MATCHES + FILE_KEYWORD_MATCH_COUNT))
    #file_matches_count["$nix_file"]="$FILE_KEYWORD_MATCH_COUNT"

    if ! "$SUMMARY_REPORT"; then
      echo "--- Search Results for: $nix_file ---"
      if [ -n "$LIMIT_RESULTS" ]; then
        echo "$MATCHES" | head -n "$LIMIT_RESULTS"
      else
        echo "$MATCHES"
      fi
      echo "--- End Search Results ---"

      # Call nix_file_analyzer.sh based on flags
      if "$LIST_IMPORTS"; then
        "$NIX_FILE_ANALYZER_SCRIPT" "$nix_file" --show-imports
      else
        # Default behavior: show all reports from analyzer
        "$NIX_FILE_ANALYZER_SCRIPT" "$nix_file"
      fi
    else
      # Collect data for summary report
      # Call analyzer to get all data, then parse its output
      ANALYZER_OUTPUT=$("$NIX_FILE_ANALYZER_SCRIPT" "$nix_file" --show-imports --show-file-paths --show-generic-urls --show-flake-inputs || true)

      # Parse analyzer output to populate associative arrays
      # This part needs careful parsing of the analyzer's output format
      # For simplicity, let's assume a structured output or parse line by line
      # Example:
      #   --- Imports ---
      #     1 import ./foo.nix
      #   --- Generic URLs ---
      #     1 github:owner/repo

      # Extract imports
      while IFS= read -r line; do
          if [[ "$line" =~ ^[[:space:]]*([0-9]+)[[:space:]]+(import.*) ]]; then
              count="${BASH_REMATCH[1]}"
              item="${BASH_REMATCH[2]}"
              all_imports["$item"]=$(( ${all_imports["$item"]:-0} + count ))
          fi
      done < <(echo "$ANALYZER_OUTPUT" | sed -n '/--- Imports ---/,/--- File Paths (file: scheme) ---/{ /--- Imports ---/! { /--- File Paths (file: scheme) ---/! p } }' || true)

      # Extract file paths
      while IFS= read -r line; do
          if [[ "$line" =~ ^[[:space:]]*([0-9]+)[[:space:]]+(file:.*) ]]; then
              count="${BASH_REMATCH[1]}"
              item="${BASH_REMATCH[2]}"
              all_file_paths["$item"]=$(( ${all_file_paths["$item"]:-0} + count ))
          fi
      done < <(echo "$ANALYZER_OUTPUT" | sed -n '/--- File Paths (file: scheme) ---/,/--- Generic URLs ---/{ /--- File Paths (file: scheme) ---/! { /--- Generic URLs ---/! p } }' || true)

      # Extract generic URLs
      while IFS= read -r line; do
          if [[ "$line" =~ ^[[:space:]]*([0-9]+)[[:space:]]+(github:.*|https?://.*|git\\+https?://.*) ]]; then
              count="${BASH_REMATCH[1]}"
              item="${BASH_REMATCH[2]}"
              all_generic_urls["$item"]=$(( ${all_generic_urls["$item"]:-0} + count ))
              if "$GROUP_BY_URL"; then
                url_to_files["$item"]+="$nix_file "
              fi
          fi
      done < <(echo "$ANALYZER_OUTPUT" | sed -n '/--- Generic URLs ---/,/--- Flake Input URLs ---/{ /--- Generic URLs ---/! { /--- Flake Input URLs ---/! p } }' || true)

      # Extract flake input URLs
      while IFS= read -r line; do
          if [[ "$line" =~ ^[[:space:]]*([0-9]+)[[:space:]]+(github:.*|https?://.*|git\\+https?://.*) ]]; then
              count="${BASH_REMATCH[1]}"
              item="${BASH_REMATCH[2]}"
              all_flake_input_urls["$item"]=$(( ${all_flake_input_urls["$item"]:-0} + count ))
              if "$GROUP_BY_URL"; then
                url_to_files["$item"]+="$nix_file "
              fi
          fi
      done < <(echo "$ANALYZER_OUTPUT" | sed -n '/--- Flake Input URLs ---/,/--- Derivation Analysis ---/{ /--- Flake Input URLs ---/! { /--- Derivation Analysis ---/! p } }' || true)
    fi
  fi
done

echo "Search complete."

if "$SUMMARY_REPORT"; then
  echo "--- Consolidated Summary Report ---"
  echo "Total files matching '$SEARCH_KEYWORD': $MATCHING_FILES_COUNT"
  echo "Total occurrences of '$SEARCH_KEYWORD': $TOTAL_KEYWORD_MATCHES"

  if "$GROUP_BY_URL"; then
    echo "--- Grouped by URL ---"
    for url in "${!url_to_files[@]}"; do
      echo "URL: $url"
      echo "  Files: ${url_to_files[$url]}"
    done | sort
  else
    echo "--- All Imports ---"
    for item in "${!all_imports[@]}"; do
        echo "${all_imports[$item]} $item"
    done | sort -rn

    echo "--- All File Paths (file: scheme) ---"
    for item in "${!all_file_paths[@]}"; do
        echo "${all_file_paths[$item]} $item"
    done | sort -rn

    echo "--- All Generic URLs ---"
    for item in "${!all_generic_urls[@]}"; do
        echo "${all_generic_urls[$item]} $item"
    done | sort -rn

    echo "--- All Flake Input URLs ---"
    for item in "${!all_flake_input_urls[@]}"; do
        echo "${all_flake_input_urls[$item]} $item"
    done | sort -rn
  fi
fi
