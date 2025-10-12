#!/usr/bin/env bash

OUTPUT_DIR="/data/data/com.termux.nix/files/home/pick-up-nix2/source/github/meta-introspector/streamofrandom/2025/index/pkg"
NIX_FILES_LIST="/data/data/com.termux.nix/files/home/pick-up-nix2/source/github/meta-introspector/streamofrandom/2025/index/nix_files.txt"

# Ensure the output directory exists
mkdir -p "$OUTPUT_DIR"

# Clear previous usage files
rm -f "$OUTPUT_DIR"/*/usage.txt

# Get the list of all .nix files (assuming it's already generated or can be generated)
# For now, let's assume the glob command from before is sufficient to get the list.
# In a real scenario, this list would be passed or generated here.
# For demonstration, I'll use a placeholder for the file list.
# In the next step, I'll populate NIX_FILES_LIST with the actual glob output.

# Placeholder for NIX_FILES_LIST content (will be replaced)
# echo "/path/to/file1.nix" > "$NIX_FILES_LIST"
# echo "/path/to/file2.nix" >> "$NIX_FILES_LIST"

# Read the list of .nix files and process each one
while IFS= read -r line; do
    nix_file=$(echo "$line" | awk '{print $NF}')
    # Find usages of pkgs. and nixpkgs. and extract the package name
    # Using -oP for Perl-regexp and only-matching
    # Look for 'pkgs.' or 'nixpkgs.' followed by a word character (package name)
    grep -oP "(pkgs|nixpkgs)\.\K\w+" "$nix_file" | while IFS= read -r package_name; do
        # Create a directory for the package if it doesn't exist
        mkdir -p "$OUTPUT_DIR/$package_name"
        # Append the file path to the package's usage.txt
        echo "$nix_file" >> "$OUTPUT_DIR/$package_name/usage.txt"
    done
done < "$NIX_FILES_LIST"

# Deduplicate entries in each usage.txt file
for usage_file in "$OUTPUT_DIR"/*/usage.txt; do
    if [ -f "$usage_file" ]; then
        sort -u "$usage_file" -o "$usage_file"
    fi
done

echo "Nix package usage documentation generated and deduplicated in $OUTPUT_DIR"
