#!/usr/bin/env bash

set -euo pipefail

TEST_DIR="tests"
OUTPUT_FILE="${TEST_DIR}/test_output.txt"

# cleanup() {
#   echo "Cleaning up test directory..."
#   rm -rf "${TEST_DIR}"
# }

# trap cleanup EXIT

echo "Running shellcheck on scripts..."
if ! shellcheck nix-llm-context/debug_wrapper.sh; then
  echo "Shellcheck of debug_wrapper.sh failed. Exiting."
  exit 1
fi

if ! shellcheck nix-llm-context/generate_monster_group_llm_txt.sh; then
  echo "Shellcheck of generate_monster_group_llm_txt.sh failed. Exiting."
  exit 1
fi

echo "Creating dummy test files..."
mkdir -p "${TEST_DIR}/wikipedia_cache" "${TEST_DIR}/docs/memes"
echo "<html><body><h1>Test Symbol</h1><p>This is a dummy HTML content for Test Symbol.</p></body></html>" > "${TEST_DIR}/wikipedia_cache/test_dummy_html.html"
printf "#!/usr/bin/env bash\n" > "${TEST_DIR}/docs/memes/test_dummy_keywords.sh"
printf "echo 'test keyword'\n" >> "${TEST_DIR}/docs/memes/test_dummy_keywords.sh"
chmod +x "${TEST_DIR}/docs/memes/test_dummy_keywords.sh"
echo "https://example.com/test_symbol_link" > "${TEST_DIR}/docs/memes/test_dummy_links.md"
echo "This is a dummy TikTok tutorial for test_symbol." > "${TEST_DIR}/docs/memes/test_dummy_tutorial.md"

echo "Running generate_monster_group_llm_txt.sh..."
if ! ./nix-llm-context/generate_monster_group_llm_txt.sh \
  --symbol="Test Symbol" \
  --html-file-name="${TEST_DIR}/wikipedia_cache/test_dummy_html.html" \
  --keywords-script="${TEST_DIR}/docs/memes/test_dummy_keywords.sh" \
  --links-file-name="${TEST_DIR}/docs/memes/test_dummy_links.md" \
  --tutorials-pattern="test_dummy_tutorial.md" \
  --output-dir="${TEST_DIR}" \
  --main-project="."; then
  echo "Script execution failed. Exiting."
  exit 1
fi

echo "Verifying output file content..."
EXPECTED_CONTENT=$(cat "${TEST_DIR}/expected_output.txt")

ACTUAL_CONTENT=$(cat "${OUTPUT_FILE}")

echo "DEBUG: EXPECTED_CONTENT starts with: ${EXPECTED_CONTENT:0:50}"
echo "DEBUG: ACTUAL_CONTENT starts with: ${ACTUAL_CONTENT:0:50}"

if ! diff <(echo -e "${EXPECTED_CONTENT}") <(echo -e "${ACTUAL_CONTENT}"); then
  echo "Test failed: Output content mismatch."
  echo "--- Expected ---"
  echo -e "${EXPECTED_CONTENT}"
  echo "--- Actual ---"
  echo -e "${ACTUAL_CONTENT}"
  exit 1
else
  echo "Test passed: Output content matches expected content."
fi

echo "--- Keyword Frequency Analysis ---"
# Convert to lowercase, remove punctuation, split into words, count frequency
ACTUAL_CONTENT_CLEANED=$(echo "${ACTUAL_CONTENT}" | tr '[:upper:]' '[:lower:]' | sed 's/[[:punct:]]//g')

# Use grep -oP to extract words, sort, unique -c to count
# Requires GNU grep for -oP, which is usually available in Nix environments
# Fallback for non-GNU grep: tr -s ' ' '\n' | sort | uniq -c | sort -nr

if grep --version | head -1 | grep -q GNU; then
  echo "${ACTUAL_CONTENT_CLEANED}" | grep -oP '\b\w+\b' | sort | uniq -c | sort -nr | head -n 10
else
  echo "GNU grep not found, using fallback for keyword frequency."
  echo "${ACTUAL_CONTENT_CLEANED}" | tr -s ' ' '\n' | sort | uniq -c | sort -nr | head -n 10
fi

echo "All tests completed successfully."