{
  description = "Nix flake to build the Hackathon Mycology Workflow PlantUML diagram.";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
    flake-utils.url = "github:meta-introspector/flake-utils?ref=feature/CRQ-016-nixify";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        inherit (pkgs) lib;

        # Placeholder for monster_genome_data and formal_triad_env
        # In a real scenario, these would be imported from other flakes or defined more robustly.
        monster_genome_data = {
          Duality = "2^46";
          Structure = "3^20";
        };
        formal_triad_env = {
          lean4_verifier = pkgs.writeText "lean4-verifier" "lean4 verifier placeholder";
          minizinc_solver = pkgs.writeText "minizinc-solver" "minizinc solver placeholder";
        };

        mycologyWorkflowPuml = import ../../theory/hackathon_mycology_workflow.puml.nix {
          inherit pkgs lib monster_genome_data formal_triad_env;
        };
      in
      {
        packages.default = mycologyWorkflowPuml;
      }
    );
}