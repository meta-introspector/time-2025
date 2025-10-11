{
  description = "Nix flake for searching a keyword in a list of files.";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify-workflow";
    flake-utils.url = "github:meta-introspector/flake-utils?ref=feature/CRQ-016-nixify-workflow";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        lib = nixpkgs.lib;

        # Function to search for a keyword in a list of files
        # filesList: A derivation containing a list of file paths (one per line)
        # keyword: The keyword to search for
        searchKeywordInFiles = { filesList, keyword, name ? "keyword-search-results" }:
          pkgs.runCommand name {
            nativeBuildInputs = [ pkgs.bash pkgs.gnugrep ];
            inherit filesList keyword;
          } ''
            echo "Searching for '${keyword}' in files from ${filesList}..."
            local found_files=()
            
            while IFS= read -r file; do
              if [ -f "$file" ] && grep -q -w "$keyword" "$file"; then
                found_files+=("$file")
              fi
            done < "$filesList"
            
            if [ ${#found_files[@]} -gt 0 ]; then
              echo "Found '${keyword}' in the following files:" >&2
              for file in "${found_files[@]}"; do
                echo "$file" >&2
                grep -w -C 3 "$keyword" "$file" >&2 # Print 3 lines of context
                echo "---" >&2
              done
              echo "Search results saved to $out"
              printf "%s\n" "${found_files[@]}" > $out
            else
              echo "No occurrences of '${keyword}' found." >&2
              echo "(empty)" > $out
            fi
          '';

      in
      {
        lib = { inherit searchKeywordInFiles; };
      }
    );
}
