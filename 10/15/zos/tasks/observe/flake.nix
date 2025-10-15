{
  description = "ZOS Observe task: Analyzes the current system state.";
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
          description = "ZOS Observe task: Analyzes the current system state.";
          flakeInputs = lib.attrNames self.inputs;
          system = system;
        };
      in
      {
        packages.default = { projectPath, loopInfo }: pkgs.runCommand "observation-report"
          {
            inherit projectPath;
            nativeBuildInputs = [ pkgs.jq ]; # Add jq as a build input
          } ''
          set -x
          mkdir -p $out # Explicitly create the output directory
          echo "{ \"observedProject\": \"$projectPath\", \"status\": \"observed\" }" | jq . > $out/report.json
        '';

        checks.healthcheck = healthcheckData;
      });
}
