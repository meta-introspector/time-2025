#!/usr/bin/env bash

# This script generates `uncommitted.nix` files in directories with uncommitted changes.
# Each `uncommitted.nix` file contains a list of uncommitted files in that directory.

set -euo pipefail

# Associative array to group files by directory
declare -A dir_files

# Read uncommitted files from git status
while IFS= read -r line; do
  # Skip deleted files
  if [[ "$line" == D* ]]; then
    continue
  fi
  # Skip submodules
  if [[ "$line" == *M* ]]; then
    continue
  fi

  # Extract the file path
  file_path=$(echo "$line" | awk '{$1=""; print $0}' | sed 's/^[[:space:]]*//')

  # Get the directory of the file
  dir_name=$(dirname "$file_path")

  # Get the base name of the file
  base_name=$(basename "$file_path")

  # Add the file to the associative array for its directory
  dir_files["$dir_name"]+=" ./$base_name"
done < <(git status --porcelain)

# Generate uncommitted.nix for each directory
for dir in "${!dir_files[@]}"; do
  files=${dir_files[$dir]}
  output_file="$dir/uncommitted.nix"

  echo "Generating $output_file..."

  # Create the Nix file content
  cat > "$output_file" <<EOF
{
  uncommittedFiles = [
  $files
  ];
}
EOF
done

echo "Generation of uncommitted.nix files complete."
