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
          let
            searchScript = pkgs.writeShellScript "search-script" ''
              set -euo pipefail
              searchNumber="$1"
              searchPatternsJson="$2"
              projectRoot="$3"
              out="$4"

              echo "Searching for '${searchNumber}' in files matching ${searchPatternsJson}..."
              
              # Convert glob patterns to regex
              patterns_regex=$(echo "$searchPatternsJson" | ${pkgs.jq}/bin/jq -r '.[]' | sed 's/\./\\./g; s/\*/.*/g; s/\?/./g; s/\*\*\//.*/g' | paste -sd '|' -)
              found_files=()

              # Find all files within projectRoot and filter by regex pattern, then check content
              ${pkgs.findutils}/bin/find "$projectRoot" -type f -print0 | while IFS= read -r -d $'\0' file; do
                if echo "$file" | ${pkgs.gnugrep}/bin/grep -qE "$patterns_regex"; then # Filter by path pattern
                  if ${pkgs.gnugrep}/bin/grep -q -w "$searchNumber" "$file"; then # Check content
                    found_files+=("$file")
                  fi
                fi
              done
              
              if [ ${#found_files[@]} -gt 0 ]; then
                echo "Found '${searchNumber}' in the following files:" >&2
                for file in "${found_files[@]}"; do
                  echo "$file" >&2
                  ${pkgs.gnugrep}/bin/grep -w -C 3 "$searchNumber" "$file" >&2 # Print 3 lines of context
                  echo "---" >&2
                done
                echo "Search results saved to $out"
                printf "%s\n" "${found_files[@]}" > "$out"
              else
                echo "No occurrences of '${searchNumber}' found." >&2
                echo "(empty)" > "$out"
              fi
            '';
          in
          pkgs.runCommand "search-for-${toString number}" {
            nativeBuildInputs = [ pkgs.bash pkgs.gnugrep pkgs.findutils pkgs.jq ];
            inherit (lib) toJSON;
          } ''
            "$searchScript" "${toString number}" "${toJSON filePatterns}" "${self}" "$out"
          '';

      in
      {
        lib = { inherit searchNumberInFiles; };
      }
    );
}
