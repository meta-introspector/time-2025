{
  description = "A flake for performing n-gram analysis on its own source.";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
  };

  outputs = { self, nixpkgs, ... }:
    let
      system = builtins.currentSystem; # Dynamically get the current system architecture
      pkgs = import nixpkgs { inherit system; };
      inherit (pkgs) lib;

      # Import the n_gram_generator.nix function from the main project's theory directory
      nGramGenerator = import ../../09/theory/n_gram_generator.nix { inherit lib pkgs builtins; };

      # The target source is 'self' (this flake's source path)
      targetSource = self; # self here refers to the flake's source path

      # Create a derivation to collect all text content from the target flake's source
      collectedTextDerivation = pkgs.runCommand "${baseNameOf targetSource}-collected-text"
        {
          src = targetSource; # The source of this flake
          nativeBuildInputs = [ pkgs.findutils pkgs.bash ];
        } ''
        # Create a temporary file to store concatenated content
        temp_content_file="$TMPDIR/all_content.txt"
        touch "$temp_content_file"

        # Find all regular files within the source and concatenate their content
        # We use -L to follow symlinks, -print0 and xargs -0 to handle special characters in filenames
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
        name = "${baseNameOf targetSource}-2gram-analysis";
      };

    in
    {
      packages.${system}.default = nGramAnalysis;

      devShells.${system}.default = pkgs.mkShell {
        packages = with pkgs; [
          nix
          nixpkgs-fmt
          statix
        ];
      };
    };
}
