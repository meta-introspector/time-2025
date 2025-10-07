{
  description = "Combines FOAF context and seed graph into a full graph.";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
    flake-utils.url = "github:meta-introspector/flake-utils?ref=feature/CRQ-016-nixify";
    foafAggregatorContextFlake.url = "./../context"; # Relative path to the aggregator context flake
    foafAggregatorSeedGraphFlake.url = "./../seed-graph"; # Relative path to the aggregator seed graph flake
  };

  outputs = { self, nixpkgs, flake-utils, foafAggregatorContextFlake, foafAggregatorSeedGraphFlake }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        inherit (pkgs) lib;

        # Get the FOAF context from the aggregator context flake
        inherit (foafAggregatorContextFlake.lib) foafContext;
        # Get the seed graph from the aggregator seed graph flake
        inherit (foafAggregatorSeedGraphFlake.lib) seedGraph;

        # Combine them into a full graph
        fullGraph = { "@context" = foafContext; "@graph" = seedGraph; };
      in
      {
        lib = {
          inherit fullGraph;
        };
      }
    );
}
