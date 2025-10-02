{
  description = "Exposes the FOAF seed graph from foafSeedDataFlake.";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
    flake-utils.url = "github:meta-introspector/flake-utils?ref=feature/CRQ-016-nixify";
    foafSeedDataFlake.url = "./../../seed-data"; # Relative path to the foafSeedDataFlake
  };

  outputs = { self, nixpkgs, flake-utils, foafSeedDataFlake }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        lib = pkgs.lib;
      in
      {
        lib = {
          seedGraph = foafSeedDataFlake.lib.seedGraph;
        };
      }
    );
}
