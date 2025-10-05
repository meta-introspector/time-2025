
{
  description = "Root flake for the CRQ search lattice, aggregating sub-flakes for testing.";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
    flake-utils.url = "github:meta-introspector/flake-utils?ref=feature/CRQ-016-nixify";
    parser = {
      url = "./parser"; # Reference the local parser flake
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
      inputs.base.follows = "base"; # Ensure base is followed
    };
    base = {
      url = "./base"; # Reference the local base flake
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
    layer1 = {
      url = "./layer1"; # Reference the local layer1 flake
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
      inputs.base.follows = "base"; # Ensure base is followed
    };
  };

  outputs = { self, nixpkgs, flake-utils, parser, base, layer1 }:
    let
      system = "aarch64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      # Expose a test output for the parser function
      tests.parserTest = {
        value = parser.lib.parseCrqFilename "CRQ_001_Log_Analysis_Pure_Derivation.md";
      };

      packages.${system}.default = pkgs.runCommand "crq-search-lattice-success" {
        meta.description = "Root flake for the CRQ search lattice, aggregating sub-flakes for testing.";
      } "echo 'CRQ Search Lattice flake built successfully!' > $out";

      packages.${system}.layer1 = layer1.packages.${system}.default; # Expose layer1's default package
    };
}
