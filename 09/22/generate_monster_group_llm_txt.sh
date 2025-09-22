#!/usr/bin/env bash
#
# Script to generate the "LLM.txt" for the "Monster Group" symbol.

set -euo pipefail

SYMBOL_NAME="Monster Group"
HTML_FILE="wikipedia_cache/Monster_group.html"
KEYWORDS_SCRIPT="./extract_meaningful_keywords.sh"
LINKS_FILE="all_extracted_links.md"
TUTORIALS_PATTERN="*monster_group*_tiktok_tutorial.md"
OUTPUT_FILE="monster_group_llm.txt"

{
echo "# $SYMBOL_NAME - LLM Context"
echo ""
} > "$OUTPUT_FILE"

{
echo "## Wikipedia Content"
# Include raw HTML content
cat "$HTML_FILE"
echo ""
} >> "$OUTPUT_FILE"

{
echo "## Extracted Keywords"
"$KEYWORDS_SCRIPT" "$HTML_FILE" 10 | sed 's/^[ ]*[0-9]* //g'
echo ""
} >> "$OUTPUT_FILE"

{
echo "## Related Links"
grep -i "Monster_group" "$LINKS_FILE"
echo ""
} >> "$OUTPUT_FILE"

{
echo "## Related TikTok Tutorials"
find . -maxdepth 1 -type f -name "$TUTORIALS_PATTERN" | sed 's#./##' | while read -r tutorial; do
    echo "- $tutorial"
done
echo ""
} >> "$OUTPUT_FILE"

echo "Generated $OUTPUT_FILE for $SYMBOL_NAME."
