#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status.
set -e

# Source the lib_exec.sh library for execute_cmd
source "/data/data/com.termux.nix/files/home/pick-up-nix2/source/github/meta-introspector/streamofrandom/2025/09/22/lib/lib_exec.sh"

FILE_PATH="$1"
TOP_N="${2:-10}" # Default to top 10 if not provided

if [ -z "$FILE_PATH" ]; then
    execute_cmd echo "Usage: $0 <html_file_path> [top_n_keywords]"
    exit 1
fi

# 1. Remove script and style tags, then remove all other HTML tags
# 2. Extract words, convert to lowercase
# 3. Filter out common English stopwords (a basic list for now)
# 4. Count unique occurrences and sort by frequency
execute_cmd bash -c "< \"$FILE_PATH\" \
    sed -E 's#<script[^>]*>.*?</script>#<script></script>#g' | \
    sed -E 's#<style[^>]*>.*?</style>#<style></style>#g' | \
    sed -E 's#<[^>]*>##g' | \
    grep -o -E '[a-zA-Z]{2,}' | \
    tr '[:upper:]' '[:lower:]' | \
    grep -v -E '\b(the|of|and|a|to|in|is|it|that|for|on|with|as|by|at|from|an|be|this|have|has|was|were|are|or|but|not|can|will|if|which|what|when|where|who|how|do|does|did|he|she|it|we|you|they|i|me|him|her|us|them|my|your|his|her|its|our|their|so|up|out|down|then|than|also|much|many|some|any|all|each|every|both|either|neither|such|only|just|even|still|yet|already|always|never|often|seldom|usually|rarely|sometimes|ever|once|twice|three|four|five|six|seven|eight|nine|ten|one|two|three|four|five|six|seven|eight|nine|ten|zero|first|second|third|fourth|fifth|sixth|seventh|eighth|ninth|tenth|eleven|twelve|thirteen|fourteen|fifteen|sixteen|seventeen|eighteen|nineteen|twenty|thirty|forty|fifty|sixty|seventy|eighty|ninety|hundred|thousand|million|billion|trillion)\b' | \
    sort | uniq -c | sort -nr | head -n \"$TOP_N\"
"
