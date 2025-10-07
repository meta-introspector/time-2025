#!/usr/bin/env bash

STATIX_OUTPUT_FILE="statix_output.txt"

if [ ! -f "$STATIX_OUTPUT_FILE" ]; then
  echo "Error: Statix output file '$STATIX_OUTPUT_FILE' not found." >&2
  exit 1
fi

echo "--- Statix Linting Summary ---"

# Total Warnings
TOTAL_WARNINGS=$(grep -c "Warning:" "$STATIX_OUTPUT_FILE")
echo "Total Warnings: $TOTAL_WARNINGS"

echo ""

# Top 3 Files with Warnings
echo "Top 3 Files with Warnings:"
grep "Warning:" "$STATIX_OUTPUT_FILE" | grep -oP '\K[^:]+' | sort | uniq -c | sort -nr | head -n 3 || true

echo ""

# Top 10 Most Frequent Warning Types
echo "Top 10 Most Frequent Warning Types:"
grep "Warning:" "$STATIX_OUTPUT_FILE" | grep -oP 'W[0-9]+' | sort | uniq -c | sort -nr | head -n 10 || true

echo "----------------------------"