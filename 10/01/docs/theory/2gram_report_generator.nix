{ lib,
  pkgs,
  builtins,
  ... 
}: 

let 
  # Function to generate a text-based report of 2-gram counts and top 2-grams.
  # Designed for a 25x80 character display.
  generate2GramReport = { 
    twoGramIndexJsonPath, # Path to the nix-2gram-index.json file
    name ? "2gram-report",
  }:
  pkgs.runCommand name {
    inherit twoGramIndexJsonPath;
    nativeBuildInputs = [ pkgs.jq ]; # For parsing JSON
  }
  ''
    mkdir -p $out
    REPORT_FILE=$out/2gram-report.txt

    # Read and parse the 2-gram index
    INDEX_CONTENT=$(cat "${twoGramIndexJsonPath}")
    
    # Calculate total unique 2-grams
    TOTAL_UNIQUE_2GRAMS=$(echo "$INDEX_CONTENT" | jq 'length')

    # Calculate total 2-gram occurrences (sum of counts)
    TOTAL_2GRAM_OCCURRENCES=$(echo "$INDEX_CONTENT" | jq '[.[] | .count] | add')

    # Get top 2-grams (top 46)
    # Sort by count in descending order, then format and take the first 46
    TOP_2GRAMS=$(echo "$INDEX_CONTENT" | jq -r 'sort_by(.count) | reverse | .[] | "\(.value) (Count: \(.count), Paths: \(.uniquePaths | length))"' | head -n 46)

    # --- Report Generation ---
    echo "┌──────────────────────────────────────────────────────────────────────────────┐" > $REPORT_FILE
    echo "│                     Nix 2-Gram Analysis Report (25x80)                     │" >> $REPORT_FILE
    echo "├──────────────────────────────────────────────────────────────────────────────┤" >> $REPORT_FILE
    echo "│ Total Unique 2-Grams: $(printf "% -53s" "$TOTAL_UNIQUE_2GRAMS") │" >> $REPORT_FILE
    echo "│ Total 2-Gram Occurrences: $(printf "% -49s" "$TOTAL_2GRAM_OCCURRENCES") │" >> $REPORT_FILE
    echo "├──────────────────────────────────────────────────────────────────────────────┤" >> $REPORT_FILE
    echo "│ Top 46 Most Frequent 2-Grams:                                                │" >> $REPORT_FILE
    echo "├──────────────────────────────────────────────────────────────────────────────┤" >> $REPORT_FILE
    
    # Add top 46 2-grams, padding to fit 80 chars
    LINE_COUNT=0
    echo "$TOP_2GRAMS" | while IFS= read -r line; do
      if [ $LINE_COUNT -lt 46 ]; then # Ensure we print up to 46 lines for top 2-grams
        printf "│ %-76s │\n" "$line" >> $REPORT_FILE
        LINE_COUNT=$((LINE_COUNT + 1))
      fi
    done

    # Fill remaining lines if less than 46 top 2-grams (to maintain consistent page height)
    while [ $LINE_COUNT -lt 46 ]; do
      echo "│                                                                              │" >> $REPORT_FILE
      LINE_COUNT=$((LINE_COUNT + 1))
    done

    echo "├──────────────────────────────────────────────────────────────────────────────┤" >> $REPORT_FILE
    echo "│ (Generated from project Nix file paths)                                      │" >> $REPORT_FILE
    echo "└──────────────────────────────────────────────────────────────────────────────┘" >> $REPORT_FILE

    echo "2-gram report generated at $out/2gram-report.txt" >&2
  '';

in
{
  generate2GramReport = generate2GramReport;
}
