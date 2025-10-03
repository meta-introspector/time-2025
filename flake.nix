{
  description = "Top-level flake for the streamofrandom/2025 project, orchestrating single-concept flakes.";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
    flake-utils.url = "github:meta-introspector/flake-utils?ref=feature/CRQ-016-nixify";
    foafAggregatorFlake.url = "./flakes/foaf/aggregator";
    foafGithubDataFlake.url = "./flakes/foaf/github-data";
  };

  outputs = { self, nixpkgs, flake-utils, foafAggregatorFlake, foafGithubDataFlake, ... }:
    let
      system = "aarch64-linux"; # Explicitly define system for debugging
      pkgs = nixpkgs.legacyPackages.${system};
      streamofrandom09Outputs = (import ./09/flake.nix).outputs { inherit nixpkgs flake-utils self; };
    in {
      devShell = streamofrandom09Outputs.${system}.devShells.default;
      lib = {
        inherit (foafAggregatorFlake.${system}.lib) foafContext seedGraph fullGraph;
        inherit (foafGithubDataFlake.${system}.lib) githubEntities;
      };
    };