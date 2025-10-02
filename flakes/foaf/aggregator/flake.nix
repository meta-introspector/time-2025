{
  description = "Aggregates FOAF context and seed data into a single graph.";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
    flake-utils.url = "github:meta-introspector/flake-utils?ref=feature/CRQ-016-nixify";
    foafContextFlake.url = "./../context";
    foafSeedDataFlake.url = "./../seed-data";
    # New inputs for the atomic aggregator flakes
    foafAggregatorContextFlake.url = "./context";
    foafAggregatorSeedGraphFlake.url = "./seed-graph";
    foafAggregatorFullGraphFlake.url = "./full-graph";
  };

  outputs = { self, nixpkgs, flake-utils, foafContextFlake, foafSeedDataFlake,
              foafAggregatorContextFlake, foafAggregatorSeedGraphFlake, foafAggregatorFullGraphFlake }:
    {
      # Wrap the eachDefaultSystem call in a set
      perSystem = flake-utils.lib.eachDefaultSystem (system:
        {
          # Temporarily return a simple set to debug syntax error
          foo = "bar";
        }
      );
    };
}
