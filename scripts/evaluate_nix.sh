#!/usr/bin/env bash
set -euo pipefail



# Function to run a Nix command and capture structured output
run_nix_command() {
  local target_path="$1" # This will be the attribute path or drvPath
  local op_type="derivation-show"
  local nix_cmd="nix derivation show \"$target_path\""
  local start_time
  start_time=$(date +%s.%N)
  local exit_code=0
  local output
  local error_output

  # Execute command and capture output/error
  local tmp_stdout
  tmp_stdout=$(mktemp)
  local tmp_stderr
  tmp_stderr=$(mktemp)

  eval "$nix_cmd" > "$tmp_stdout" 2> "$tmp_stderr"
  exit_code=$?

  output=$(cat "$tmp_stdout")
  error_output=$(cat "$tmp_stderr")

  rm "$tmp_stdout" "$tmp_stderr"

  local end_time
  end_time=$(date +%s.%N)
  local duration
  duration=$(echo "$end_time - $start_time" | bc)

  # Construct JSON output
  jq -n \
    --arg target_path "$target_path" \
    --arg op_type "$op_type" \
    --arg output "$output" \
    --arg error_output "$error_output" \
    --argjson exit_code "$exit_code" \
    --arg duration "$duration" \
    '{ "target_path": $target_path, "operation": $op_type, "output": $output, "error_output": $error_output, "exit_code": $exit_code, "duration": $duration }'
}

# Find all flake.nix files
echo "Discovering flake.nix files..."
FLAKE_FILES=()
while IFS= read -r -d $'' file; do
  FLAKE_FILES+=("$file")
done < <(find "$FLAKE_ROOT" -type f -name "flake.nix" -print0)

if [ ${#FLAKE_FILES[@]} -eq 0 ]; then
  echo "No flake.nix files found in $FLAKE_ROOT"
  exit 0
fi

echo "Found ${#FLAKE_FILES[@]} flake.nix files."

ALL_DERIVATION_REPORTS=()

# Process each flake
for flake_file in "${FLAKE_FILES[@]}"; do
  FLAKE_DIR=$(dirname "$flake_file")
  echo "--- Processing flake: $FLAKE_DIR ---"

  # Get all derivation paths from the flake
  # Using 'nix flake show --json' and jq to extract drvPath for packages and devShells
  DERIVATION_PATHS=()
  NIX_FLAKE_SHOW_OUTPUT=$(nix flake show --json "$FLAKE_DIR" 2>/dev/null || true)

  if [ -n "$NIX_FLAKE_SHOW_OUTPUT" ]; then
    # Extract drvPaths from packages
    mapfile -t PKG_DRV_PATHS < <(echo "$NIX_FLAKE_SHOW_OUTPUT" | jq -r '.packages."x86_64-linux" | to_entries[] | .value.drvPath // empty' 2>/dev/null || true)
    DERIVATION_PATHS+=("${PKG_DRV_PATHS[@]}")

    # Extract drvPaths from devShells
    mapfile -t SHELL_DRV_PATHS < <(echo "$NIX_FLAKE_SHOW_OUTPUT" | jq -r '.devShells."x86_64-linux" | to_entries[] | .value.drvPath // empty' 2>/dev/null || true)
    DERIVATION_PATHS+=("${SHELL_DRV_PATHS[@]}")
  fi

  if [ ${#DERIVATION_PATHS[@]} -eq 0 ]; then
    echo "No derivations found for flake: $FLAKE_DIR"
    continue
  fi

  echo "Found ${#DERIVATION_PATHS[@]} derivations for $FLAKE_DIR."

  CURRENT_FLAKE_DERIVATION_RESULTS=()
  for drv_path in "${DERIVATION_PATHS[@]}"; do
    echo "  Running nix derivation show for: $drv_path"
    DRV_SHOW_RESULT=$(run_nix_command "$drv_path")
    CURRENT_FLAKE_DERIVATION_RESULTS+=("$DRV_SHOW_RESULT")
  done

  # Aggregate results for the current flake into a single JSON object
  jq -n \
    --arg flake_path "$FLAKE_DIR" \
    --arg timestamp "$(date -Iseconds)" \
    --argjson results "$(printf '%s\n' "${CURRENT_FLAKE_DERIVATION_RESULTS[@]}" | jq -s .)" \
    '{ "flake_path": $flake_path, "timestamp": $timestamp, "derivation_results": $results }' > "$FLAKE_DIR/derivation_report.json"

  ALL_DERIVATION_REPORTS+=("$(cat "$FLAKE_DIR/derivation_report.json")")

  echo "Generated derivation report for $FLAKE_DIR: $FLAKE_DIR/derivation_report.json"
  echo ""
done

# Aggregate all flake reports into a single JSON file
jq -n \
  --argjson flakes "$(printf '%s\n' "${ALL_DERIVATION_REPORTS[@]}" | jq -s .)" \
  '{ "flakes_derivation_analysis": $flakes }' > "$FLAKE_ROOT/$REPORT_FILE"

TOTAL_FLAKES=$(jq '.flakes_derivation_analysis | length' "$FLAKE_ROOT/$REPORT_FILE")
TOTAL_DERIVATIONS=$(jq '[.flakes_derivation_analysis[].derivation_results | length] | add' "$FLAKE_ROOT/$REPORT_FILE")

echo "--- Derivation Analysis Summary ---"
echo "Processed $TOTAL_FLAKES flakes."
echo "Found a total of $TOTAL_DERIVATIONS derivations across all flakes."
echo "Full report available in $FLAKE_ROOT/$REPORT_FILE"