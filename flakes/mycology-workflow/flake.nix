{
  description = "Nix flake to build the Hackathon Mycology Workflow PlantUML diagram.";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
    flake-utils.url = "github:meta-introspector/flake-utils?ref=feature/CRQ-016-nixify";

    # Collection of data sources (Wikidata, Wikipedia, etc.)
    sources = {
      url = "github:meta-introspector/time-2025?ref=feature/lattice-30030-homedir&dir=flakes/data-sources"; # Point to the data-sources flake in the current repo
      inputs = {
        nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
        flake-utils.url = "github:meta-introspector/flake-utils?ref=feature/CRQ-016-nixify";
      };
    };
  };

  outputs = { self, nixpkgs, flake-utils, sources, topLevelSelf }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        inherit (pkgs) lib;

        # Placeholder for monster_genome_data and formal_triad_env
        # In a real scenario, these would be imported from other flakes or defined more robustly.
        monster_genome_data = {
          Duality = "2^46";
          Structure = "3^20";
          # Dynamic model for partial DNA match derived from samples
          partial_dna_match = {
            key_patterns = [ "2^46" "3^20" "71^1" ]; # Example key patterns
            source_samples = [
              sources.wikidata.Monster_Group.passthru.articleName # Reference to Wikidata Monster Group NAR
              sources.wikipedia.Monster_Group.passthru.articleName # Reference to Wikipedia Monster Group cache
              sources.wikipedia.Articles.passthru.articleName # Reference to Wikipedia Articles
            ];
            analysis_timestamp = "2025-10-07T12:00:00Z"; # Timestamp of analysis
            # Add more dynamic attributes as needed
          };
        };
        formal_triad_env = {
          lean4_verifier = pkgs.writeText "lean4-verifier" "lean4 verifier placeholder";
          minizinc_solver = pkgs.writeText "minizinc-solver" "minizinc solver placeholder";
        };

        mycologyWorkflowPuml = import (topLevelSelf + "/theory/hackathon_mycology_workflow.puml.nix") {
          inherit pkgs lib monster_genome_data formal_triad_env;
        };
      in
      {
        packages.default = mycologyWorkflowPuml;
      }
    );
}