{
  description = "Top-level flake for the streamofrandom/2025 project, orchestrating single-concept flakes.";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
    flake-utils.url = "github:meta-introspector/flake-utils?ref=feature/CRQ-016-nixify";
    foafAggregatorFlake.url = "github:meta-introspector/time-2025/feature/foaf?dir=flakes/foaf/aggregator";
    foafGithubDataFlake.url = "github:meta-introspector/time-2025/feature/foaf?dir=flakes/foaf/github-data";
    search-results.url = "github:meta-introspector/time-2025/feature/foaf?dir=flakes/search-results";
  };

  outputs = { self, nixpkgs, flake-utils, foafAggregatorFlake, foafGithubDataFlake, search-results, ... }:
    let
      system = "aarch64-linux"; # Explicitly define system for debugging
      pkgs = nixpkgs.legacyPackages.${system};
      streamofrandom09Outputs = (import ./09/flake.nix).outputs { inherit nixpkgs flake-utils self search-results; };
    in {
      devShell = streamofrandom09Outputs.${system}.devShells.default;
      lib = {
        inherit (foafAggregatorFlake.${system}.lib) foafContext seedGraph fullGraph;
        inherit (foafGithubDataFlake.${system}.lib) githubEntities;
      };
    };
}