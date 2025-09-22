#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status.
set -euo pipefail

# Source the lib_exec.sh library for execute_cmd
source "$(dirname "$0")/lib/lib_exec.sh"

SYMBOL_NAME="$1"

if [ -z "$SYMBOL_NAME" ]; then
  execute_cmd echo "Usage: $0 <SYMBOL_NAME>"
  exit 1
fi

# Convert symbol name to lowercase and replace spaces with underscores for filenames
SYMBOL_LOWER=$(echo "$SYMBOL_NAME" | tr '[:upper:]' '[:lower:]' | sed 's/ /_/g')

execute_cmd echo "Creating LLM context template for symbol: $SYMBOL_NAME"

# Create the new directory for the LLM context
NEW_DIR="nix-llm-context-${SYMBOL_LOWER}"
execute_cmd mkdir -p "$NEW_DIR"

# Create flake.nix content
FLAKE_NIX_CONTENT=$(cat <<EOF
{
  description = "Nix flake for generating LLM context for ${SYMBOL_NAME}.";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
    flake-utils.url = "github:meta-introspector/flake-utils?ref=feature/CRQ-016-nixify";
    mainProject.url = "path:../";
  };

  outputs = { self, nixpkgs, flake-utils, mainProject }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        lib = pkgs.lib;
      in
      rec {
        packages.${SYMBOL_LOWER}LlmContext = pkgs.runCommand "llm-context-${SYMBOL_NAME// /-}" {
          buildInputs = [ pkgs.bash pkgs.coreutils pkgs.gnugrep pkgs.gnused pkgs.findutils pkgs.file pkgs.which ];
          buildCommand = ''
            "${self}/debug_wrapper.sh" \
              --generator-script="${self}/generate_${SYMBOL_LOWER}_llm_txt.sh" \
              --symbol="${SYMBOL_NAME}" \
              --html-file-name="${SYMBOL_NAME// /_}.html" \
              --keywords-script="${mainProject}/docs/memes/extract_meaningful_keywords.sh" \
              --links-file-name="${mainProject}/docs/memes/all_extracted_links.md" \
              --tutorials-pattern="" \
              --output-dir="$out" \
              --main-project="${mainProject}"
          '';
        } "";
      }
    );
}
EOF
)

# Create generate_SYMBOL_NAME_llm_txt.sh content
GENERATOR_SCRIPT_CONTENT=$(cat <<EOF
#!/usr/bin/env bash
#
# Script to generate the "LLM.txt" for a given symbol (${SYMBOL_NAME}).
# Arguments are now read from positional arguments.

set -euo pipefail

# Parse named arguments
while [[ "$#" -gt 0 ]]; do
  case "$1" in
    --symbol)
      SYMBOL_NAME="$2"
      shift
      ;;
    --symbol=*)
      SYMBOL_NAME="${1*=}"
      ;;
    --html-file-name)
      HTML_FILE="$2"
      shift
      ;;
    --html-file-name=*) 
      HTML_FILE="${1*=}"
      ;;
    --keywords-script)
      KEYWORDS_SCRIPT="$2"
      shift
      ;;
    --keywords-script=*)
      KEYWORDS_SCRIPT="${1*=}"
      ;;
    --links-file-name)
      LINKS_FILE="$2"
      shift
      ;;
    --links-file-name=*)
      LINKS_FILE="${1*=}"
      ;;
    --tutorials-pattern)
      TUTORIALS_PATTERN="$2"
      shift
      ;;
    --tutorials-pattern=*)
      TUTORIALS_PATTERN="${1*=}"
      ;;
    --main-project)
      MAIN_PROJECT="$2"
      shift
      ;;
    --main-project=*)
      MAIN_PROJECT="${1*=}"
      ;;
    --output-dir)
      OUTPUT_DIR="$2"
      shift
      ;;
    --output-dir=*)
      OUTPUT_DIR="${1*=}"
      ;;
    *)
      echo "Unknown parameter passed: $1" >&2
      exit 1
      ;;
  esac
  shift
done

# Assign parsed values to original script variables
OUTPUT_FILE_NAME="llm-context-${SYMBOL_NAME// /-}.txt" # Construct output file name
OUTPUT_FILE_PATH="${OUTPUT_DIR}/${OUTPUT_FILE_NAME}"

# Ensure all required variables are set
if [ -z "$SYMBOL_NAME" ] || [ -z "$HTML_FILE" ] || [ -z "$KEYWORDS_SCRIPT" ] || [ -z "$LINKS_FILE" ] || [ -z "$TUTORIALS_PATTERN" ] || [ -z "$OUTPUT_DIR" ] || [ -z "$MAIN_PROJECT" ]; then
  echo "Error: Missing required arguments." >&2
  exit 1
fi

# Create a temporary file to build the content
TEMP_OUTPUT_FILE=$(mktemp)

{
echo "# $SYMBOL_NAME - LLM Context"
echo ""

echo "## Source Information"
echo "- Main Project Path: $MAIN_PROJECT"
echo ""

echo "## Wikipedia Content"
cat "$HTML_FILE"
echo ""

echo "## Extracted Keywords"
"$KEYWORDS_SCRIPT" "$HTML_FILE" 10 | sed 's/^[ ]*[0-9]* //g'
echo ""

echo "## Related Links"
grep -i "${SYMBOL_NAME// /_}" "$LINKS_FILE" || true
echo ""

echo "## Related Tutorials"
SOURCE_ROOT=$(dirname "$(dirname "$HTML_FILE")")
FILENAME_TUTORIALS_PATTERN=$(basename "$TUTORIALS_PATTERN")

if [ -n "$FILENAME_TUTORIALS_PATTERN" ]; then
  find "$SOURCE_ROOT" -maxdepth 2 -type f -name "$FILENAME_TUTORIALS_PATTERN" -printf "- %P\n"
fi

echo ""
} > "$TEMP_OUTPUT_FILE"

# Copy the generated content to the final output path
mkdir -p "$(dirname "$OUTPUT_FILE_PATH")"
cp "$TEMP_OUTPUT_FILE" "$OUTPUT_FILE_PATH"

# Clean up the temporary file
# rm "$TEMP_OUTPUT_FILE"

echo "Generated $OUTPUT_FILE_PATH for $SYMBOL_NAME."
EOF
)

# Write flake.nix
execute_cmd echo "$FLAKE_NIX_CONTENT" > "$NEW_DIR/flake.nix"

# Write generator script
execute_cmd echo "$GENERATOR_SCRIPT_CONTENT" > "$NEW_DIR/generate_${SYMBOL_LOWER}_llm_txt.sh"

# Copy debug_wrapper.sh
execute_cmd cp "nix-llm-context/debug_wrapper.sh" "$NEW_DIR/debug_wrapper.sh"

execute_cmd chmod +x "$NEW_DIR/generate_${SYMBOL_LOWER}_llm_txt.sh"
execute_cmd chmod +x "$NEW_DIR/debug_wrapper.sh"

execute_cmd echo "Template for ${SYMBOL_NAME} created in ${NEW_DIR}/"
execute_cmd echo "Remember to update the html-file-name and tutorials-pattern in ${NEW_DIR}/flake.nix as needed."
