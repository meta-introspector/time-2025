{
  description = "ZOS Decide task: Chooses concrete actions based on orientation.";
  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
    flake-utils.url = "github:meta-introspector/flake-utils?ref=feature/CRQ-016-nixify";
    self = { url = "github:meta-introspector/time-2025?ref=feature/aimyc-003-cultivation"; }; # Reference to the repository root
  };
  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let pkgs = nixpkgs.legacyPackages.${system}; in
      {
        packages.default = { orientationDecision }: pkgs.runCommand "action-plan" {
          inherit orientationDecision;
        } ''
          echo "Deciding actions based on: $orientationDecision" > $out/plan.json
          echo "{ \"actions\": [ { \"type\": \"dwim\", \"prompt\": \"a simple game\" } ], \"status\": \"planned\" }" > $out/plan.json
        '';
      });
}
