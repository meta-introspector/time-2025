#!/usr/bin/env bash

set -euo pipefail

# Define dummy paths and values
MAIN_PROJECT_DUMMY="$(pwd)"
HTML_FILE_NAME_DUMMY="Monster_group.html"
KEYWORDS_SCRIPT_FILE_NAME_DUMMY="extract_meaningful_keywords.sh"
LINKS_FILE_NAME_DUMMY="all_extracted_links.md"
TUTORIALS_PATTERN_DUMMY="*monster_group*_tiktok_tutorial.md"
OUTPUT_DIR_DUMMY="$(pwd)/nix-simulated-output"
SYMBOL_DUMMY="Monster Group"
GENERATOR_SCRIPT_DUMMY="nix-llm-context/generate_monster_group_llm_txt.sh"

# Create dummy files and directories
mkdir -p "${MAIN_PROJECT_DUMMY}/wikipedia_cache"
mkdir -p "${MAIN_PROJECT_DUMMY}/docs/memes"
mkdir -p "${OUTPUT_DIR_DUMMY}"

echo "<html><body><h1>Monster Group</h1><p>This is a dummy HTML content for Monster Group.</p></body></html>" > "${MAIN_PROJECT_DUMMY}/wikipedia_cache/${HTML_FILE_NAME_DUMMY}"
echo "#!/usr/bin/env bash
echo 'dummy keyword'" > "${MAIN_PROJECT_DUMMY}/docs/memes/${KEYWORDS_SCRIPT_FILE_NAME_DUMMY}"
chmod +x "${MAIN_PROJECT_DUMMY}/docs/memes/${KEYWORDS_SCRIPT_FILE_NAME_DUMMY}"
echo "https://example.com/monster_group_link" > "${MAIN_PROJECT_DUMMY}/docs/memes/${LINKS_FILE_NAME_DUMMY}"
echo "This is a dummy TikTok tutorial for monster_group." > "${MAIN_PROJECT_DUMMY}/docs/memes/${TUTORIALS_PATTERN_DUMMY}"

cleanup() {
  echo "Cleaning up dummy files and directories..."
  # rm -rf "${MAIN_PROJECT_DUMMY}/wikipedia_cache"
  # rm -rf "${MAIN_PROJECT_DUMMY}/docs/memes"
  # rm -rf "${OUTPUT_DIR_DUMMY}"
}

trap cleanup EXIT

# Run debug_wrapper.sh with dummy arguments
./nix-llm-context/debug_wrapper.sh \
  --generator-script="${GENERATOR_SCRIPT_DUMMY}" \
  --symbol="${SYMBOL_DUMMY}" \
  --html-file-name="${HTML_FILE_NAME_DUMMY}" \
  --keywords-script="${KEYWORDS_SCRIPT_FILE_NAME_DUMMY}" \
  --links-file-name="${LINKS_FILE_NAME_DUMMY}" \
  --tutorials-pattern="${TUTORIALS_PATTERN_DUMMY}" \
  --output-dir="${OUTPUT_DIR_DUMMY}" \
  --main-project="${MAIN_PROJECT_DUMMY}"

echo "Simulation complete. Check ${OUTPUT_DIR_DUMMY}/llm-context-Monster-Group.txt for output."