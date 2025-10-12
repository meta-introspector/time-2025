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
        inherit (nixpkgs) lib;

        # Function to search for a keyword in a list of files
        # filesList: A derivation containing a list of file paths (one per line)
        # keyword: The keyword to search for
        searchKeywordInFiles = { filesList, keyword, name ? "keyword-search-results" }:
          pkgs.runCommand name
            {
              nativeBuildInputs = [ pkgs.bash pkgs.gnugrep ];
              inherit filesList keyword;
              searchScript = ./search-script.sh;
            } "${searchScript} ${keyword} ${filesList} $out";

      in
      {
        lib = { inherit searchKeywordInFiles; };
      }
    );
}

