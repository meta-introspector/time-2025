{
  description = "ZOS Decide task: Chooses concrete actions based on orientation.";
  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
    flake-utils.url = "github:meta-introspector/flake-utils?ref=feature/CRQ-016-nixify";
    self = { url = "github:meta-introspector/time-2025?ref=feature/aimyc-003-cultivation"; }; # Reference to the repository root
  };
  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        lib = pkgs.lib;
        healthcheckData = {
          healthy = true;
          description = "ZOS Decide task: Chooses concrete actions based on orientation.";
          flakeInputs = lib.attrNames self.inputs;
          system = system;
        };
      in
      {
        packages.default = { orientationDecision }: pkgs.runCommand "action-plan"
          {
            inherit orientationDecision;
            nativeBuildInputs = [ pkgs.jq ]; # Add jq as a build input
          } ''
          set -x
          mkdir -p $out # Explicitly create the output directory
          echo "{ \"actions\": [ { \"type\": \"dwim\", \"prompt\": \"a simple game\" } ], \"status\": \"planned\" }" | jq . > $out/plan.json
        '';
        checks.healthcheck = healthcheckData;

        # Add a new package for testing with dummy inputs
        packages.testOutput = self.packages.${system}.default {
          orientationDecision = "dummy-orientation";
        };
      });
}
