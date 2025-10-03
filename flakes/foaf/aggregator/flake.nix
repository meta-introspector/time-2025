{
  description = "Aggregates FOAF context and seed data into a single graph.";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
    foafContextFlake.url = "github:meta-introspector/time-2025/feature/foaf?dir=flakes/foaf/context";
    foafSeedDataFlake.url = "github:meta-introspector/time-2025/feature/foaf?dir=flakes/foaf/seed-data";
  };

  outputs = { self, nixpkgs, foafContextFlake, foafSeedDataFlake }:
    let
      system = "aarch64-linux"; # Hardcoded system
      pkgs = nixpkgs.legacyPackages.${system};
      lib = pkgs.lib;

      # Get the FOAF context from the context flake
      foafContext = foafContextFlake.lib.foafContext;
      # Get the seed graph from the seed data flake
      seedGraph = foafSeedDataFlake.lib.seedGraph;

      # Combine them into a full graph (initially just seed data with context)
      fullGraph = { "@context" = foafContext; "@graph" = seedGraph; };
    in
    {
      lib = {
        inherit foafContext seedGraph fullGraph;
      };
    };
}
