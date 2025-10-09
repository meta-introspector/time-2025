#!/usr/bin/env bash
set -euo pipefail

#!/usr/bin/env bash
set -euo pipefail

NIX_FILE="$1"
shift # Shift past the NIX_FILE argument

# Default to showing all reports
SHOW_IMPORTS=true
SHOW_FILE_PATHS=true
SHOW_GENERIC_URLS=true
SHOW_FLAKE_INPUTS=true
SHOW_DERIVATIONS=true

# Function to display usage for nix_file_analyzer.sh
usage_analyzer() {
  echo "Usage: $0 <nix_file> [--show-imports] [--show-file-paths] [--show-generic-urls] [--show-flake-inputs] [--show-derivations]"
  echo "  <nix_file>         : Required. The Nix file to analyze."
  echo "  --show-imports     : Optional. Show import statements."
  echo "  --show-file-paths  : Optional. Show file: paths."
  echo "  --show-generic-urls: Optional. Show generic URLs (http, github, etc.)."
  echo "  --show-flake-inputs: Optional. Show flake input URLs (only for flake.nix files)."
  echo "  --show-derivations : Optional. Show derivation analysis (only for flake.nix files)."
  echo "If no --show-* flags are provided, all reports are shown."
  exit 1
}

# Parse arguments for nix_file_analyzer.sh
# If any --show-* flag is present, disable all defaults first
if [[ "$#" -gt 0 ]]; then
  SHOW_IMPORTS=false
  SHOW_FILE_PATHS=false
  SHOW_GENERIC_URLS=false
  SHOW_FLAKE_INPUTS=false
  SHOW_DERIVATIONS=false
fi

while [[ "$#" -gt 0 ]]; do
  case "$1" in
    --show-imports) SHOW_IMPORTS=true ;;
    --show-file-paths) SHOW_FILE_PATHS=true ;;
    --show-generic-urls) SHOW_GENERIC_URLS=true ;;
    --show-flake-inputs) SHOW_FLAKE_INPUTS=true ;;
    --show-derivations) SHOW_DERIVATIONS=true ;;
    *) echo "Unknown parameter passed to analyzer: $1"; usage_analyzer ;;
  esac
  shift
done

echo "--- Analysis for: $NIX_FILE ---"

declare -A import_counts
declare -A file_path_counts
declare -A url_counts
declare -A flake_input_counts

if "$SHOW_IMPORTS"; then
  # Extract imports
  while IFS= read -r line; do
      import_counts["$line"]=$(( ${import_counts["$line"]:-0} + 1 ))
  done < <(grep -oE 'import +(\<[^>]+\>|\./[^ ]+|\.\./[^ ]+)' "$NIX_FILE" || true)
fi

if "$SHOW_FILE_PATHS"; then
  # Extract file: paths
  while IFS= read -r line; do
      file_path_counts["$line"]=$(( ${file_path_counts["$line"]:-0} + 1 ))
  done < <(grep -oE 'file:(\./[^ ]+|/[^ ]+)' "$NIX_FILE" || true)
fi

if "$SHOW_GENERIC_URLS"; then
  # Extract generic URLs
  while IFS= read -r line; do
      url_counts["$line"]=$(( ${url_counts["$line"]:-0} + 1 ))
  done < <(grep -oE '(github:[^ ]+|https?://[^ ]+|git\\+https?://[^ ]+)' "$NIX_FILE" || true)
fi

if "$SHOW_FLAKE_INPUTS"; then
  # Extract flake inputs (URLs) if it's a flake.nix
  if [[ "$(basename "$NIX_FILE")" == "flake.nix" ]]; then
      FLAKE_DIR=$(dirname "$NIX_FILE")
      NIX_FLAKE_METADATA=$(nix flake metadata --json "$FLAKE_DIR" 2>/dev/null || true)
      if [ -n "$NIX_FLAKE_METADATA" ]; then
          FLAKE_INPUT_URLS=$(echo "$NIX_FLAKE_METADATA" | jq -r '.inputs | to_entries[] | .value.url' || true)
          if [ -n "$FLAKE_INPUT_URLS" ]; then
              while IFS= read -r line; do
                  flake_input_counts["$line"]=$(( ${flake_input_counts["$line"]:-0} + 1 ))
              done < <(echo "$FLAKE_INPUT_URLS")
          fi
      fi
  fi
fi

if "$SHOW_IMPORTS"; then
  echo "  --- Imports ---"
  for item in "${!import_counts[@]}"; do
      echo "    ${import_counts[$item]} $item"
done | sort -rn
fi

if "$SHOW_FILE_PATHS"; then
  echo "  --- File Paths (file: scheme) ---"
  for item in "${!file_path_counts[@]}"; do
      echo "    ${file_path_counts[$item]} $item"
done | sort -rn
fi

if "$SHOW_GENERIC_URLS"; then
  echo "  --- Generic URLs ---"
  for item in "${!url_counts[@]}"; do
      echo "    ${url_counts[$item]} $item"
done | sort -rn
fi

if "$SHOW_FLAKE_INPUTS"; then
  echo "  --- Flake Input URLs ---"
  for item in "${!flake_input_counts[@]}"; do
      echo "    ${flake_input_counts[$item]} $item"
done | sort -rn
fi

if "$SHOW_DERIVATIONS"; then
  echo "  --- Derivation Analysis ---"
  if [[ "$(basename "$NIX_FILE")" == "flake.nix" ]]; then
      FLAKE_DIR=$(dirname "$NIX_FILE")
      DERIVATION_PATHS=()
      NIX_FLAKE_SHOW_OUTPUT=$(nix flake show --json "$FLAKE_DIR" 2>/dev/null || true)

      if [ -n "$NIX_FLAKE_SHOW_OUTPUT" ]; then
          mapfile -t PKG_DRV_PATHS < <(echo "$NIX_FLAKE_SHOW_OUTPUT" | jq -r '.packages."x86_64-linux" | to_entries[] | .value.drvPath // empty' 2>/dev/null || true)
          DERIVATION_PATHS+=("${PKG_DRV_PATHS[@]}")

          mapfile -t SHELL_DRV_PATHS < <(echo "$NIX_FLAKE_SHOW_OUTPUT" | jq -r '.devShells."x86_64-linux" | to_entries[] | .value.drvPath // empty' 2>/dev/null || true)
          DERIVATION_PATHS+=("${SHELL_DRV_PATHS[@]}")
      fi

      if [ ${#DERIVATION_PATHS[@]} -eq 0 ]; then
          echo "    No derivations found for flake: $FLAKE_DIR"
      else
          echo "    Found ${#DERIVATION_PATHS[@]} derivations for $FLAKE_DIR."
      fi
  else
      echo "    Not a flake.nix file, skipping derivation analysis."
  fi
fi

echo "--------------------------------------------------------------------------------"
