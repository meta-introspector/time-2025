{
  description = "ZOS Orchestrator: Coordinates the Act, Decide, and Observe tasks.";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
    flake-utils.url = "github:meta-introspector/flake-utils?ref=feature/CRQ-016-nixify";
    self = { url = "github:meta-introspector/time-2025?ref=feature/aimyc-003-cultivation"; }; # Reference to the repository root

    actFlake = { url = "path:./tasks/act"; };
    decideFlake = { url = "path:./tasks/decide"; };
    observeFlake = { url = "path:./tasks/observe"; };
  };

  outputs = { self, nixpkgs, flake-utils, actFlake, decideFlake, observeFlake }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        lib = pkgs.lib;

        # 1. Decide Phase
        decideOutput = decideFlake.packages.${system}.default {
          orientationDecision = "initial-orientation-for-orchestrator";
        };

        # Extract plan.json from decideOutput
        decidePlan = pkgs.runCommand "decide-plan-extractor"
          {
            planFile = "${decideOutput}/plan.json";
          }
          ''
            cat $planFile > $out
          '';

        # 2. Act Phase
        actOutput = actFlake.packages.${system}.default {
          actionPlan = decidePlan; # Pass the plan as actionPlan
          dwimFlake = { lib = { ${system} = { dwim = "/nix/store/dummy-dwim"; }; }; }; # Dummy dwimFlake
        };

        # Extract new-state.json from actOutput
        actState = pkgs.runCommand "act-state-extractor"
          {
            stateFile = "${actOutput}/new-state.json";
          }
          ''
            cat $stateFile > $out
          '';

        # 3. Combine outputs for Observe Phase
        combinedState = pkgs.runCommand "combined-state"
          {
            inherit decidePlan actState;
            nativeBuildInputs = [ pkgs.jq ];
          }
          ''
            set -x
            mkdir -p $out
            jq -n \
              --argjson decide "$(cat $decidePlan)" \
              --argjson act "$(cat $actState)" \
              '{ decide: $decide, act: $act }' > $out
          '';

        # 4. Observe Phase
        observeReport = observeFlake.packages.${system}.default {
          currentState = combinedState; # Pass the combined state
        };

      in
      {
        packages.${system}.default = observeReport; # The orchestrator's default output is the observe report

        checks.healthcheck = {
          healthy = true;
          description = self.description;
          flakeInputs = lib.attrNames self.inputs;
          system = system;
        };
      });
}
