{
  description = "Nix flake to build the Hackathon Mycology Workflow PlantUML diagram.";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
    flake-utils.url = "github:meta-introspector/flake-utils?ref=feature/CRQ-016-nixify";
    consolidated-impure-gemini-telemetry.url = "github:meta-introspector/time-2025?ref=feature/lattice-30030-homedir&dir=09/27/7-concepts/6-qa-testing/tests/consolidated-impure-gemini-telemetry";
  };

  outputs = { self, nixpkgs, flake-utils, dataSources, consolidated-impure-gemini-telemetry, filePath, ... } @ args:
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
              dataSources.wikidata.Monster_Group.passthru.articleName # Reference to Wikidata Monster Group NAR
              dataSources.wikipedia.Monster_Group.passthru.articleName # Reference to Wikipedia Monster Group cache
              dataSources.wikipedia.Articles.passthru.articleName # Reference to Wikipedia Articles
            ];
            analysis_timestamp = "2025-10-07T12:00:00Z"; # Timestamp of analysis
            # Add more dynamic attributes as needed
          };
        };
        formal_triad_env = {
          lean4_verifier = pkgs.writeText "lean4-verifier" "lean4 verifier placeholder";
          minizinc_solver = pkgs.writeText "minizinc-solver" "minizinc solver placeholder";
        };

        # Define mycologyContext to pass to Gemini
        mycologyContext = {
          inherit (args) sopsSecretsPath; # Example: pass sopsSecretsPath
          # Add other context relevant to GMP, QA, SOPs, logs, records here
        };

        mycologyWorkflowPuml = import args.vial.packages.${system}.default {
          inherit pkgs lib monster_genome_data formal_triad_env;
        };

        # Invoke the consolidated-impure-gemini-telemetry flake
        # This will run the telemetry script and produce logs/telemetry
        geminiFruitingBody = consolidated-impure-gemini-telemetry.outputs.default { 
          inherit (args) vial filePath mycologyContext; 
        };
      in
      {
        packages.default = geminiFruitingBody;
      }
    );
}