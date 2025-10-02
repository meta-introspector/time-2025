{
  description = "Aggregates FOAF context and seed data into a single graph.";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
    flake-utils.url = "github:meta-introspector/flake-utils?ref=feature/CRQ-016-nixify";
    foafContextFlake.url = "./../context";
    foafSeedDataFlake.url = "./../seed-data";
    foafAggregatorContextFlake.url = "./context";
    foafAggregatorSeedGraphFlake.url = "./seed-graph";
    foafAggregatorFullGraphFlake.url = "./full-graph";
  };

  outputs = { self, nixpkgs, flake-utils, foafContextFlake, foafSeedDataFlake,
              foafAggregatorContextFlake, foafAggregatorSeedGraphFlake, foafAggregatorFullGraphFlake }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        lib = pkgs.lib;
      in
      {
        lib = {
          inherit (foafAggregatorContextFlake.lib) foafContext;
          inherit (foafAggregatorSeedGraphFlake.lib) seedGraph;
          inherit (foafAggregatorFullGraphFlake.lib) fullGraph;
        };
      }
    );
}