{ pkgs, lib, targetFlake }:

let
  # Import the n_gram_generator.nix function
  nGramGenerator = import ./09/theory/n_gram_generator.nix { inherit lib pkgs builtins; };

  # Create a derivation to collect all text content from the target flake's source
  collectedTextDerivation = pkgs.runCommand "${targetFlake.name or "target-flake"}-collected-text"
    {
      src = targetFlake.self; # The source of the input flake
      nativeBuildInputs = [ pkgs.findutils pkgs.bash ];
    } ''
    # Create a temporary file to store concatenated content
    temp_content_file="$TMPDIR/all_content.txt"
    touch "$temp_content_file"

    # Find all regular files within the source and concatenate their content
    # We use -L to follow symlinks, -print0 and xargs -0 to handle special characters in filenames
    # Filter out directories and non-regular files
    find -L "$src" -type f -print0 | while IFS= read -r -d '\0' file; do
      if [ -f "$file" ]; then # Ensure it's a regular file
        cat "$file" >> "$temp_content_file"
        echo "" >> "$temp_content_file" # Add a newline between file contents
      fi
    done

    # Copy the collected text to the output
    cp "$temp_content_file" "$out"
  '';

  # Call the n_gram_generator with the collected text
  nGramAnalysis = nGramGenerator.generateNGrams {
    text = builtins.readFile collectedTextDerivation; # Pass the collected text as a string
    n = 2; # Default to 2-gram, can be made configurable
    name = "${targetFlake.name or "target-flake"}-2gram-analysis";
  };

in
nGramAnalysis
