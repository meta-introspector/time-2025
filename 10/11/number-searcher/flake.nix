{
  description = "Nix flake for searching a given number in specified file types across the project.";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify-workflow";
    flake-utils.url = "github:meta-introspector/flake-utils?ref=feature/CRQ-016-nixify-workflow";
    self = {
      url = "github:meta-introspector/time-2025?ref=feature/CRQ-016-nixify-workflow"; # Project root
    };
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        inherit (nixpkgs) lib;

        # Function to search for a number in files matching given patterns
        # number: The number to search for (string or int)
        # filePatterns: A list of glob patterns for files to search (e.g., ["**/*.md", "**/*.nix"])
        searchNumberInFiles = { number, filePatterns }:
          pkgs.runCommand "search-for-${toString number}"
            {
              nativeBuildInputs = [ pkgs.bash pkgs.gnugrep pkgs.findutils pkgs.jq ];
              inherit (lib) toJSON;
              searchScript = ./search-script.sh;
            } "${searchScript} ${toString number} ${toJSON filePatterns} ${self} $out";

      in
      {
        lib = { inherit searchNumberInFiles; };
      }
    );
}

