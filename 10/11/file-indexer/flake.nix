{
  description = "Nix flake for indexing all files in a given path and generating a files.txt.";

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

        # Function to find all files in a given path and output a files.txt
        indexAllFiles = { path, name ? "all-files-index" }:
          pkgs.runCommand name
            {
              nativeBuildInputs = [ pkgs.bash pkgs.findutils ];
              searchPath = path;
            } ''
            echo "Indexing all files in ${searchPath}..."
            find "${searchPath}" -type f > $out
            echo "File list generated at $out"
          '';

      in
      {
        lib = { inherit indexAllFiles; };
      }
    );
}
