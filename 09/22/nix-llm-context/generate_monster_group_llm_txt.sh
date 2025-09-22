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
OUTPUT_FILE="${LLM_OUTPUT_FILE}"

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
# Find tutorials relative to the current directory (which is $src in the Nix build)
# The find command needs to search within the source directory passed as $src
# from the Nix derivation.
find "$(dirname "$HTML_FILE")"/.. -maxdepth 2 -type f -name "$TUTORIALS_PATTERN" -printf "- %P\n"
echo ""
} > "$OUTPUT_FILE"

echo "Generated $OUTPUT_FILE for $SYMBOL_NAME."