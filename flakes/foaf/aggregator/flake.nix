{
  description = "Aggregates FOAF context and seed data into a single graph.";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
    flake-utils.url = "github:meta-introspector/flake-utils?ref=feature/CRQ-016-nixify";
    foafContextFlake.url = "./../context";
    foafSeedDataFlake.url = "./../seed-data";
  };

  outputs = { self, nixpkgs, flake-utils, foafContextFlake, foafSeedDataFlake }:
    {
      # Temporarily return a simple set to debug syntax error
      foo = "bar";
    };
}