#!/usr/bin/env bash
#
# Script to generate the "LLM.txt" for a given symbol.
# Arguments:
#   $1: SYMBOL_NAME (e.g., "Monster Group")
#   $2: HTML_FILE_PATH (e.g., "../wikipedia_cache/Monster_group.html")
#   $3: KEYWORDS_SCRIPT_PATH (e.g., "../extract_meaningful_keywords.sh")
#   $4: LINKS_FILE_PATH (e.g., "../all_extracted_links.md")
#   $5: TUTORIALS_PATTERN (e.g., "*monster_group*_tiktok_tutorial.md")
#   $6: OUTPUT_FILE_PATH (e.g., "$out/llm-context-Monster Group.txt")

set -euo pipefail

SYMBOL_NAME="$1"
HTML_FILE="$2"
KEYWORDS_SCRIPT="$3"
LINKS_FILE="$4"
TUTORIALS_PATTERN="$5"
OUTPUT_FILE="$6"

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
find .. -maxdepth 2 -type f -name "$TUTORIALS_PATTERN" | sed 's#../##' | while read -r tutorial; do
    echo "- $tutorial"
done
echo ""
} > "$OUTPUT_FILE"

echo "Generated $OUTPUT_FILE for $SYMBOL_NAME."
