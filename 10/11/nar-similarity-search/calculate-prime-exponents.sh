#!/usr/bin/env bash
set -euo pipefail

nar_path="$1"
primes_json="$2"
out="$3"

# Initialize an associative array for prime exponents
declare -A prime_exponents

# Parse primes from JSON into bash array
readarray -t primes_array < <(echo "$primes_json" | jq -r '.[]')

# Initialize exponents to 0
for p in "${primes_array[@]}"; do
  prime_exponents[$p]=0
done

# Extract all unique words from the NAR (simplified for this example)
# In a real scenario, this would involve more sophisticated NAR parsing
nar_content=$(nix-store --dump-path "$nar_path" | nix-nar-dump | grep -oE '\b[a-zA-Z0-9_]+\b' | sort -u)

# Calculate exponents based on word occurrences
for word in $nar_content; do
  # For each word, calculate its Gödel number and factorize it
  # This is a placeholder for actual Gödel numbering and factorization
  # For now, we'll just increment exponents for some primes based on word length
  word_length=${#word}
  if (( word_length % 2 == 0 )); then
    if [[ -v prime_exponents["2"] ]]; then
      prime_exponents["2"]=$((prime_exponents["2"] + 1))
    fi
  fi
  if (( word_length % 3 == 0 )); then
    if [[ -v prime_exponents["3"] ]]; then
      prime_exponents["3"]=$((prime_exponents["3"] + 1))
    fi
  fi
  # ... more complex logic for other primes
done

# Output prime exponents as JSON
json_output="{"
first=true
for prime in "${!prime_exponents[@]}"; do
  if [ "$first" = false ]; then
    json_output+=","
  fi
  json_output+="\"${prime}\":${prime_exponents[$prime]}"
  first=false
done
json_output+="}"

echo "$json_output" > "$out"
