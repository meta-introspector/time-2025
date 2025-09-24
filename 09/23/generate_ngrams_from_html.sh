#!/usr/bin/env bash

set -euo pipefail

HTML_FILE="/data/data/com.termux.nix/files/home/pick-up-nix2/source/github/meta-introspector/streamofrandom/2025/09/22/wikipedia_cache/Ontology.html"
OUTPUT_FILE="/data/data/com.termux.nix/files/home/pick-up-nix2/source/github/meta-introspector/streamofrandom/2025/09/ontology_ngrams.json"

# Convert HTML to plain text
pandoc -s -t plain "$HTML_FILE" -o ontology.txt

# Initialize an empty JSON object
JSON_OUTPUT="{}"

# Function to generate n-grams and add to JSON
add_ngrams_to_json() {
  local n=$1
  local text_file=$2
  local ngram_type="${n}-gram"

  # Generate n-grams, count, and format for jq
  ngrams=$(<"$text_file" tr -s '[:space:]' '\n' | grep -v '^$' \
    | awk -v n="$n" '{ 
      words[NR] = $0
    }
    END {
      for (i = 1; i <= NR - n + 1; i++) {
        line = words[i]
        for (j = 1; j < n; j++) {
          line = line " " words[i+j]
        }
        print tolower(line)
      }
    }' | sort | uniq -c | sort -nr)

  # Convert to JSON array of objects
  json_ngrams=$(echo "$ngrams" | awk '{ 
    print "{\"name\": \"" $2 "\", \"value\": " $1 "}"
  }' | jq -s .)

  # Add to the main JSON output
  JSON_OUTPUT=$(echo "$JSON_OUTPUT" | jq --argjson jn "$json_ngrams" '. + { "'"$ngram_type"'": $jn }')
}

# Generate 1-grams, 2-grams, and 3-grams
add_ngrams_to_json 1 ontology.txt
add_ngrams_to_json 2 ontology.txt
add_ngrams_to_json 3 ontology.txt

# Write the final JSON output to file
echo "$JSON_OUTPUT" | jq . > "$OUTPUT_FILE"

rm ontology.txt

echo "N-grams generated and saved to $OUTPUT_FILE"
