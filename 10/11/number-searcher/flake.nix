{
  description = "Nix flake for searching a given number in specified file types across the project.";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify-workflow";
    flake-utils.url = "github:meta-introspector/flake-utils?ref=feature/CRQ-016-nixify-workflow";
    self = {
      url = "github:meta-introspector/time-2025?ref=feature/CRQ-016-nixify-workflow&dir=source/github/meta-introspector/streamofrandom/2025"; # Project root
    };
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        lib = nixpkgs.lib;

        # Function to search for a number in files matching given patterns
        # number: The number to search for (string or int)
        # filePatterns: A list of glob patterns for files to search (e.g., ["**/*.md", "**/*.nix"])
        searchNumberInFiles = { number, filePatterns }:
          pkgs.runCommand "search-for-${toString number}" {
            nativeBuildInputs = [ pkgs.bash pkgs.gnugrep pkgs.findutils ];
            searchNumber = toString number;
            searchPatterns = lib.toJSON filePatterns;
            projectRoot = self;
          } ''
            set -euo pipefail
            echo "Searching for '${searchNumber}' in files matching ${searchPatterns}..."
            
            local patterns_regex=$(echo "$searchPatterns" | jq -r '.[]' | sed 's/\./\\./g; s/\*/.*/g; s/\?/./g; s/\*\*\//.*/g' | paste -sd '|' -) # Convert glob patterns to regex
            local found_files=()

            # Find all files within projectRoot and filter by regex pattern, then check content
            find "$projectRoot" -type f -print0 | while IFS= read -r -d $'\0' file; do
              if echo "$file" | grep -qE "$patterns_regex"; then # Filter by path pattern
                if grep -q -w "$searchNumber" "$file"; then # Check content
                  found_files+=("$file")
                fi
              fi
            done
            
            if [ ${#found_files[@]} -gt 0 ]; then
              echo "Found '${searchNumber}' in the following files:" >&2
              for file in "${found_files[@]}"; do
                echo "$file" >&2
                grep -w -C 3 "$searchNumber" "$file" >&2 # Print 3 lines of context
                echo "---" >&2
              done
              echo "Search results saved to $out"
              printf "%s\n" "${found_files[@]}" > $out
            else
              echo "No occurrences of '${searchNumber}' found." >&2
              echo "(empty)" > $out
            fi
          '';

      in
      {
        lib = { inherit searchNumberInFiles; };
      }
    );
}
