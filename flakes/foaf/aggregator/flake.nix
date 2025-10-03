{
  description = "Aggregates FOAF context and seed data into a single graph.";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
    flake-utils.url = "github:meta-introspector/flake-utils?ref=feature/CRQ-016-nixify";
    foafContextFlake.url = "./../context";
    foafSeedDataFlake.url = "./../seed-data";
  };

  outputs = { self, nixpkgs, flake-utils, foafContextFlake, foafSeedDataFlake }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        # Import common pkgs and lib definitions
        commonLib = import ./lib/default.nix { inherit nixpkgs system; };
        pkgs = commonLib.pkgs;
        lib = commonLib.lib;

        # Get the FOAF context
        foafContext = import ./lib/get-foaf-context.nix { inherit foafContextFlake; };
        # Get the seed graph
        seedGraph = import ./lib/get-seed-graph.nix { inherit foafSeedDataFlake; };

        # Combine them into a full graph
        fullGraph = import ./lib/combine-full-graph.nix { inherit foafContext seedGraph; };
      in
      {
        lib = {
          inherit foafContext seedGraph fullGraph;
        };
      }
    );
}
