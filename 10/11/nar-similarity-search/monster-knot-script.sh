#!/usr/bin/env bash
set -euo pipefail

flakePath="$1"
parsedFlake="$2"
monsterPrimes="$3"
keywordMap="$4"
out="$5"

echo "Calculating Monster Knot for ${flakePath}/flake.nix..."
ast_json=$(cat "$parsedFlake")
echo "DEBUG: ast_json content: $ast_json"
monster_primes_list=$(echo "$monsterPrimes" | jq -r '.[]')
keyword_map_json="$keywordMap"

# Initialize exponents for all Monster Group primes to 0
declare -A prime_exponents
for prime in $monster_primes_list; do
  prime_exponents[$prime]=0
done

# Conceptual AST traversal and prime assignment
# This is a simplified example. A real implementation would traverse the AST
# and assign primes based on node types, attributes, etc.
# For now, we'll simulate by looking for keywords in the AST string representation.
ast_string=$(cat "$parsedFlake")

for keyword in $(echo "$keyword_map_json" | jq -r 'keys[]'); do
  if echo "$ast_string" | grep -q -w "$keyword"; then
    prime=$(echo "$keyword_map_json" | jq -r '."'"$keyword"'"')
    if [[ -n "$prime" && "$prime" != "null" ]]; then
      prime_exponents[$prime]=$((prime_exponents[$prime] + 1))
    fi
  fi
done

# Convert associative array to JSON object
json_output="{"
first=true
for prime in "${!prime_exponents[@]}"; do
  if ! "$first"; then
    json_output+=","
  fi
  json_output+="\"${prime}\":${prime_exponents[$prime]}"
  first=false
done
json_output+="}"

echo "$json_output" > "$out"
