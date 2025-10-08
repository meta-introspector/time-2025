#!/usr/bin/env bash
set -euo pipefail

KEYWORD=""
OPERATION="build" # Default operation is 'build'
FLAKE_ROOT="/data/data/com.termux.nix/files/home/pick-up-nix2/source/github/meta-introspector/streamofrandom/2025/"
REPORT_FILE="evaluation_report.json"

# Function to display usage
usage() {
  echo "Usage: $0 [-k <keyword>] [-o <operation>]"
  echo "  -k <keyword>   : Optional. Filter flakes by keyword in their path."
  echo "  -o <operation> : Optional. Operation to perform: 'build', 'check', 'develop', 'eval', or 'inspect-urls'. Default is 'build'."
  exit 1
}

# Parse arguments
while getopts "k:o:" opt; do
  case "$opt" in
    k) KEYWORD="$OPTARG" ;;
    o) OPERATION="$OPTARG" ;;
    *) usage ;;
  esac
done
shift $((OPTIND-1))

echo "Starting Nix evaluation with:"
echo "  Keyword: '$KEYWORD'"
echo "  Operation: '$OPERATION'"
echo "  Flake Root: '$FLAKE_ROOT'"
echo ""

# Function to run a Nix command and capture structured output
run_nix_command() {
  local flake_path="$1"
  local op_type="$2"
  local nix_cmd=""
  local start_time
  start_time=$(date +%s.%N)
  local exit_code=0
  local output
  local error_output

  case "$op_type" in
    build)
      nix_cmd="nix build \"$flake_path\""
      ;;
    check)
      nix_cmd="nix flake check \"$flake_path\""
      ;;
    develop)
      nix_cmd="nix develop \"$flake_path\" --command bash -c \"echo 'Entered develop shell for $flake_path'; exit\""
      ;;
    eval)
      nix_cmd="nix eval --json \"$flake_path\""
      ;;
    *)
      echo "Error: Unknown operation type '$op_type' for run_nix_command"
      return 1
      ;;
  esac

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
    --arg flake_path "$flake_path" \
    --arg op_type "$op_type" \
    --arg output "$output" \
    --arg error_output "$error_output" \
    --argjson exit_code "$exit_code" \
    --arg duration "$duration" \
    '{ "flake_path": $flake_path, "operation": $op_type, "output": $output, "error_output": $error_output, "exit_code": $exit_code, "duration": $duration }'
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

# Filter flakes if a keyword is provided
FILTERED_FLAKES=()
if [ -n "$KEYWORD" ]; then
  echo "Filtering flakes by keyword: '$KEYWORD'"
  for flake_file in "${FLAKE_FILES[@]}"; do
    if [[ "$flake_file" == *"$KEYWORD"* ]]; then
      FILTERED_FLAKES+=("$flake_file")
    fi
  done
  FLAKE_FILES=("${FILTERED_FLAKES[@]}")
  if [ ${#FLAKE_FILES[@]} -eq 0 ]; then
    echo "No flakes found matching keyword '$KEYWORD'."
    exit 0
  fi
  echo "Filtered down to ${#FLAKE_FILES[@]} flakes."
fi

ALL_FLAKE_REPORTS=()

# Process each flake
for flake_file in "${FLAKE_FILES[@]}"; do
  FLAKE_DIR=$(dirname "$flake_file")
  echo "--- Processing flake: $FLAKE_DIR ---"

  FLAKE_REPORT_JSON="$FLAKE_DIR/flake_report.json"
  CURRENT_FLAKE_RESULTS=()

  # Run build operation
  BUILD_RESULT=$(run_nix_command "$FLAKE_DIR" "build")
  CURRENT_FLAKE_RESULTS+=("$BUILD_RESULT")

  # Run check operation
  CHECK_RESULT=$(run_nix_command "$FLAKE_DIR" "check")
  CURRENT_FLAKE_RESULTS+=("$CHECK_RESULT")

  # Run develop operation
  DEVELOP_RESULT=$(run_nix_command "$FLAKE_DIR" "develop")
  CURRENT_FLAKE_RESULTS+=("$DEVELOP_RESULT")

  # Run eval operation
  EVAL_RESULT=$(run_nix_command "$FLAKE_DIR" "eval")
  CURRENT_FLAKE_RESULTS+=("$EVAL_RESULT")

  # Aggregate results for the current flake into a single JSON object
  jq -n \
    --arg flake_path "$FLAKE_DIR" \
    --arg timestamp "$(date -Iseconds)" \
    --argjson results "$(printf '%s\n' "${CURRENT_FLAKE_RESULTS[@]}" | jq -s .)" \
    '{ "flake_path": $flake_path, "timestamp": $timestamp, "results": $results }' > "$FLAKE_REPORT_JSON"

  ALL_FLAKE_REPORTS+=("$(cat "$FLAKE_REPORT_JSON")")

  echo "Generated report for $FLAKE_DIR: $FLAKE_REPORT_JSON"
  echo ""
done

# Aggregate all flake reports into a single JSON file
jq -n \
  --argjson flakes "$(printf '%s\n' "${ALL_FLAKE_REPORTS[@]}" | jq -s .)" \
  '{ "flakes_evaluation": $flakes }' > "$FLAKE_ROOT/$REPORT_FILE"

echo "All selected flakes processed successfully. Full report in $FLAKE_ROOT/$REPORT_FILE"