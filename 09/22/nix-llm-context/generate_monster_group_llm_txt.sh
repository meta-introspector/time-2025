#!/usr/bin/env bash
#
# Script to generate the "LLM.txt" for a given symbol.
# Arguments are now read from environment variables.

set -euo pipefail

SYMBOL_NAME="${LLM_SYMBOL_NAME}"
HTML_FILE="${LLM_HTML_FILE_NAME}"
KEYWORDS_SCRIPT="${LLM_KEYWORDS_SCRIPT_FILE_NAME}"
LINKS_FILE="${LLM_LINKS_FILE_NAME}"
TUTORIALS_PATTERN="${LLM_TUTORIALS_PATTERN}"
OUTPUT_FILE_PATH="${LLM_OUTPUT_FILE}" # This is the final output path in $out

# Create a temporary file to build the content
TEMP_OUTPUT_FILE=$(mktemp)

{
echo "# $SYMBOL_NAME - LLM Context"
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
find "$(dirname "$HTML_FILE")/.." -maxdepth 2 -type f -name "$TUTORIALS_PATTERN" -printf "- %P\n"
echo ""
} > "$TEMP_OUTPUT_FILE"

# Copy the generated content to the final output path
cp "$TEMP_OUTPUT_FILE" "$OUTPUT_FILE_PATH"

# Clean up the temporary file
rm "$TEMP_OUTPUT_FILE"

echo "Generated $OUTPUT_FILE_PATH for $SYMBOL_NAME."
