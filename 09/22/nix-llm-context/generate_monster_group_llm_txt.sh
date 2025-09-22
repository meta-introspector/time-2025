#!/usr/bin/env bash
#
# Script to generate the "LLM.txt" for a given symbol.
# Arguments are now read from positional arguments.

set -euo pipefail

SYMBOL_NAME="$1"
HTML_FILE="$2"
KEYWORDS_SCRIPT="$3"
LINKS_FILE="$4"
TUTORIALS_PATTERN="$5"
OUTPUT_FILE_PATH="$6" # This is the final output path in $out

MAIN_PROJECT_URL="$7"
MAIN_PROJECT_REV="$8"
# CRQ_BINSTORE_URL="$9" # Removed
# CRQ_BINSTORE_REV="${10}" # Removed

# Create a temporary file to build the content
TEMP_OUTPUT_FILE=$(mktemp)

{
echo "# $SYMBOL_NAME - LLM Context"
echo ""

echo "## Source Information"
echo "- Main Project Repository: $MAIN_PROJECT_URL (Commit: $MAIN_PROJECT_REV)"
# echo "- CRQ Binstore Repository: $CRQ_BINSTORE_URL (Commit: $CRQ_BINSTORE_REV)" # Removed
echo ""

echo "## Wikipedia Content"
cat "$HTML_FILE"
echo ""

echo "## Extracted Keywords"
"$KEYWORDS_SCRIPT" "$HTML_FILE" 10 | sed 's/^[ ]*[0-9]* //g'
echo ""

echo "## Related Links"
grep -i "${SYMBOL_NAME// /_}" "$LINKS_FILE"
echo ""

echo "## Related TikTok Tutorials"
# The find command needs to search within the source directory passed as $src
# from the Nix derivation.
# The HTML_FILE variable contains the absolute path to the HTML file within the Nix store.
# We need to find the base source directory from HTML_FILE.
# Example: HTML_FILE = /nix/store/.../wikipedia_cache/Monster_group.html
# Source directory = /nix/store/.../
# So, we need to go up two levels from HTML_FILE to get to the source root.
SOURCE_ROOT=$(dirname "$(dirname "$HTML_FILE")")

find "$SOURCE_ROOT" -maxdepth 2 -type f -name "$TUTORIALS_PATTERN" -printf "- %P\n"
echo ""
} > "$TEMP_OUTPUT_FILE"

# Copy the generated content to the final output path
cp "$TEMP_OUTPUT_FILE" "$OUTPUT_FILE_PATH"

# Clean up the temporary file
rm "$TEMP_OUTPUT_FILE"

echo "Generated $OUTPUT_FILE_PATH for $SYMBOL_NAME."
