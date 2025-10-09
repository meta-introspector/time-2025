#!/usr/bin/env bash
set -euo pipefail

mapfile -t FLAKE_FILES < <(find . -name "*.nix" -print0 | xargs -0 realpath --relative-to=.)

REPORT_FILE="nix_dependency_report.txt"

echo "Generating Nix Dependency Report..." > "$REPORT_FILE"
echo "-----------------------------------" >> "$REPORT_FILE"

declare -A import_counts
declare -A file_path_counts
declare -A url_counts
declare -A flake_input_counts

# Process each Nix file
for nix_file in "${FLAKE_FILES[@]}"; do
    echo "Processing $nix_file..."

    # Extract imports
    while IFS= read -r line; do
        import_counts["$line"]=$(( ${import_counts["$line"]:-0} + 1 ))
    done < <(grep -oE 'import +(\<[^>]+\>|\./[^ ]+|\.\./[^ ]+)' "$nix_file" || true)

    # Extract file: paths
    while IFS= read -r line; do
        file_path_counts["$line"]=$(( ${file_path_counts["$line"]:-0} + 1 ))
    done < <(grep -oE 'file:(//|\./|\.\./)[^ ]+' "$nix_file" || true)

    # Extract generic URLs
    while IFS= read -r line; do
        url_counts["$line"]=$(( ${url_counts["$line"]:-0} + 1 ))
    done < <(grep -oE '(github:[^ ]+|https?://[^ ]+|git\+https?://[^ ]+)' "$nix_file" || true)

    # Extract flake inputs (URLs) if it's a flake.nix
    if [[ "$(basename "$nix_file")" == "flake.nix" ]]; then
        FLAKE_DIR=$(dirname "$nix_file")
        NIX_FLAKE_METADATA=$(nix flake metadata --json "$FLAKE_DIR" 2>/dev/null || true)
        if [ -n "$NIX_FLAKE_METADATA" ]; then
            while IFS= read -r line; do
                flake_input_counts["$line"]=$(( ${flake_input_counts["$line"]:-0} + 1 ))
            done < <(echo "$NIX_FLAKE_METADATA" | jq -r '.inputs | to_entries[] | .value.url' || true)
        fi
    fi
done

TEMP_REPORT_SECTION=$(mktemp)
echo "--- Import Statements ---" > "$TEMP_REPORT_SECTION"
for item in "${!import_counts[@]}"; do
    echo "${import_counts[$item]} $item"
done | sort -rn >> "$TEMP_REPORT_SECTION"
cat "$TEMP_REPORT_SECTION" >> "$REPORT_FILE"
rm "$TEMP_REPORT_SECTION" # Clean up temporary file

TEMP_REPORT_SECTION=$(mktemp)
echo "--- File Paths (file: scheme) ---" > "$TEMP_REPORT_SECTION"
for item in "${!file_path_counts[@]}"; do
    echo "${file_path_counts[$item]} $item"
done | sort -rn >> "$TEMP_REPORT_SECTION"
cat "$TEMP_REPORT_SECTION" >> "$REPORT_FILE"
rm "$TEMP_REPORT_SECTION" # Clean up temporary file

TEMP_REPORT_SECTION=$(mktemp)
echo "--- Generic URLs ---" > "$TEMP_REPORT_SECTION"
for item in "${!url_counts[@]}"; do
    echo "${url_counts[$item]} $item"
done | sort -rn >> "$TEMP_REPORT_SECTION"
cat "$TEMP_REPORT_SECTION" >> "$REPORT_FILE"
rm "$TEMP_REPORT_SECTION" # Clean up temporary file

TEMP_REPORT_SECTION=$(mktemp)
echo "--- Flake Input URLs ---" > "$TEMP_REPORT_SECTION"
for item in "${!flake_input_counts[@]}"; do
    echo "${flake_input_counts[$item]} $item"
done | sort -rn >> "$TEMP_REPORT_SECTION"
cat "$TEMP_REPORT_SECTION" >> "$REPORT_FILE"
rm "$TEMP_REPORT_SECTION" # Clean up temporary file

echo "Report generated in $REPORT_FILE"
