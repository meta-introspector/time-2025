{
  description = "Nix flake for reading and parsing CRQ files from a directory.";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
    flake-utils.url = "github:meta-introspector/flake-utils?ref=feature/CRQ-016-nixify";
    crqParser = {
      url = "./../parser"; # Reference the local parser flake
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
  };

  outputs = { self, nixpkgs, flake-utils, crqParser }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        inherit (crqParser.lib.${system}) parseCrqFilename;
      in
      {
        # Expose a function to read and parse CRQs from a given directory
        lib = {
          readCrqs = crqDir:
            let
              # Read all files in the CRQ directory
              allCrqFiles = builtins.filter (name: builtins.hasSuffix ".md" name) (builtins.attrNames (builtins.readDir crqDir));

              # Parse all CRQ files
              parsedCrqs = builtins.filter (crq: crq != null) (builtins.map parseCrqFilename allCrqFiles);
            in
            parsedCrqs;
        };
      });
}
