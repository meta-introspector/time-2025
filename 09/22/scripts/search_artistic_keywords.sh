#!/usr/bin/env bash

# ==============================================================================
#
#          FILE: search_artistic_keywords.sh
#
#         USAGE: ./scripts/search_artistic_keywords.sh [--top-n N]
#
#   DESCRIPTION: This script performs a case-insensitive search for a predefined
#                list of "artistic and Muse-related keywords" within all files
#                in the 'index/' directory. By default, it compiles all matches
#                into a new subindex file.
#
#       OPTIONS:
#                --top-n N : If specified, performs a frequency analysis and
#                            outputs the N most common matching terms instead
#                            of writing all matches to a file.
#
#  REQUIREMENTS: grep, bash
#          BUGS: ---
#         NOTES: This script is part of the Artistic Policy Framework (CRQ-021)
#                and implements functionality from CRQ-025.
#        AUTHOR: Gemini
#  ORGANIZATION:
#       CREATED: 2025-09-21
#      REVISION: 1.1
#
# ==============================================================================

set -euo pipefail

# Source the utility library
PROJECT_ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." &> /dev/null && pwd )"
source "${PROJECT_ROOT}/scripts/lib_search_utils.sh"

# Define script-specific variables
SEARCH_DIR="${PROJECT_ROOT}/index"
OUTPUT_DIR="${PROJECT_ROOT}/index/art"
OUTPUT_FILE="${OUTPUT_DIR}/artistic_references.md"
PATTERN_FILE="${PROJECT_ROOT}/scripts/combined_search_patterns.txt"
SCRIPT_NAME="search_artistic_keywords.sh"
SEARCH_DESCRIPTION="artistic and Muse-related"

TOP_N_COUNT="" # Default to no top-n analysis

# --- Argument Parsing ---
while [[ "$#" -gt 0 ]]; do
    case "$1" in
        --top-n)
            if [[ -z "$2" || "$2" =~ ^-+ ]]; then
                echo "Error: --top-n requires a numeric argument." >&2
                exit 1
            fi
            TOP_N_COUNT="$2"
            shift # past argument
            ;;
        *)
            echo "Unknown parameter: $1" >&2
            exit 1
            ;;
    esac
    shift # past argument or value
done

# --- Main Logic ---

if [[ -n "${TOP_N_COUNT}" ]]; then
    # Perform top-n frequency analysis
    get_top_n_matching_terms "${PATTERN_FILE}" "${SEARCH_DIR}" "${TOP_N_COUNT}" "${OUTPUT_DIR}"
else
    # Perform regular search and save to file
    ensure_output_dir_exists "${OUTPUT_DIR}"
    write_output_header "${OUTPUT_FILE}" "${SCRIPT_NAME}" "${SEARCH_DESCRIPTION}"
    perform_grep_search "${PATTERN_FILE}" "${SEARCH_DIR}" "${OUTPUT_FILE}"
fi

exit 0
