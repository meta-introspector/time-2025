# shellcheck shell=bash
# Function to get the top N most common matching terms
# Usage: get_top_n_matching_terms "/path/to/patterns.txt" "/path/to/search/dir" N "/path/to/output/dir_to_exclude"
get_top_n_matching_terms() {
    local pattern_file="$1"
    local search_dir="$2"
    local n="$3"
    local output_dir_for_exclusion="$4" # Directory to exclude from search

    echo "Analyzing term frequency in ${search_dir} for top ${n} terms..."

    # Perform grep search to get only the matching terms (whole words or phrases)
    # -o: Only show the part of a matching line that matches PATTERN.
    # -F: Interpret PATTERN as a list of fixed strings, separated by newlines.
    # --exclude-dir: Exclude the output directory from the search.
    grep -r -i -o -f "${pattern_file}" --exclude-dir "$(basename "${output_dir_for_exclusion}")" "${search_dir}" |
    sed 's/^[^:]*://' |
    sort | uniq -c | sort -nr | head -n "${n}"
}