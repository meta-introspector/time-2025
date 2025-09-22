#!/usr/bin/env bash

set -euo pipefail

INPUT_FILE="index/flake_nix_urls_with_filenames.txt"
SED_SCRIPT="scripts/apply_vendorized_urls.sh"
META_INTROSPECTOR_ORG="meta-introspector"
TARGET_BRANCH="feature/CRQ-016-nixify"

echo "#!/usr/bin/env bash" > "$SED_SCRIPT"
echo "set -euo pipefail" >> "$SED_SCRIPT"
echo "" >> "$SED_SCRIPT"

# Read the flake_nix_urls_with_filenames.txt and generate sed commands
while IFS= read -r line; do
    # Example line: ./flake.nix:    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    # Extract filename and the full line content after the filename
    filename=$(echo "$line" | cut -d':' -f1)
    line_content=$(echo "$line" | cut -d':' -f2-)

    # Extract the URL part from line_content using awk
    url_match=$(echo "$line_content" | awk -F'url = "' '{print $2}' | awk -F'"' '{print $1}')

    if [[ -n "$url_match" ]]; then
        original_url="$url_match"
        new_url=""

        # Skip local paths, flakehub, channels, sourcehut, git.savannah.gnu.org
        if [[ "$original_url" =~ ^path:.* ]] || \
           [[ "$original_url" =~ ^https://flakehub.com.* ]] || \
           [[ "$original_url" =~ ^https://channels.nixos.org.* ]] || \
           [[ "$original_url" =~ ^sourcehut:.* ]] || \
           [[ "$original_url" =~ ^https://git.savannah.gnu.org.* ]]; then
            continue
        fi

        # Check if it's a GitHub URL (github:owner/repo or https://github.com/owner/repo)
        if [[ "$original_url" =~ ^github:([^/]+)/([^/]+)(.*)$ ]]; then
            owner="${BASH_REMATCH[1]}"
            repo_name="${BASH_REMATCH[2]}"
            # Remove .git suffix if present in repo_name
            repo_name="${repo_name%.git}"

            if [[ "$owner" != "$META_INTROSPECTOR_ORG" ]]; then
                # This is a candidate for vendorization
                new_url="github:${META_INTROSPECTOR_ORG}/${repo_name}?ref=${TARGET_BRANCH}"
            fi
        elif [[ "$original_url" =~ ^https://github.com/([^/]+)/([^/]+)(\.git)?(.*)$ ]]; then
            owner="${BASH_REMATCH[1]}"
            repo_name="${BASH_REMATCH[2]}"
            # Remove .git suffix if present in repo_name
            repo_name="${repo_name%.git}"

            if [[ "$owner" != "$META_INTROSPECTOR_ORG" ]]; then
                # This is a candidate for vendorization
                new_url="github:${META_INTROSPECTOR_ORG}/${repo_name}?ref=${TARGET_BRANCH}"
            fi
        fi

        if [[ -n "$new_url" && "$new_url" != "$original_url" ]]; then
            # Escape special characters in original_url and new_url for sed
            escaped_original_url=$(echo "$original_url" | sed -e 's/[\/&]/\\&/g')
            escaped_new_url=$(echo "$new_url" | sed -e 's/[\/&]/\\&/g')

            # Append sed command to the script
            echo "sed -i 's/${escaped_original_url}/${escaped_new_url}/g' \"$filename\"" >> "$SED_SCRIPT"
            echo "echo \"Updated $filename: $original_url -> $new_url\"" >> "$SED_SCRIPT"
        fi
    fi
done < "$INPUT_FILE"

echo "Generated URL vendorization script: $SED_SCRIPT"
chmod +x "$SED_SCRIPT"