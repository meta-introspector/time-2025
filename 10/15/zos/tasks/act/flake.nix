{
  description = "ZOS Act task: Executes the planned actions and produces new tasks/state.";
  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
    flake-utils.url = "github:meta-introspector/flake-utils?ref=feature/CRQ-016-nixify";
    dwimFlake.url = "github:meta-introspector/time-2025?ref=feature/aimyc-003-cultivation&dir=10/15/dwim"; # Need access to DWIM flake
    self = { url = "github:meta-introspector/time-2025?ref=feature/aimyc-003-cultivation"; }; # Reference to the repository root
  };
  outputs = { self, nixpkgs, flake-utils, dwimFlake }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        lib = pkgs.lib;
        healthcheckData = {
          healthy = true;
          description = "ZOS Act task: Executes the planned actions and produces new tasks/state."; # Directly embed the string
          flakeInputs = lib.attrNames self.inputs;
          system = system;
        };
      in
      {
        packages.default = { actionPlan, dwimFlake }:
          let
            dwimToolPath = dwimFlake.lib.${system}.dwim; # Extract the path
            actionPlanPath = actionPlan; # Explicitly assign actionPlan to a path variable
          in
          pkgs.runCommand "new-tasks-and-state"
            {
              ACTION_PLAN = actionPlanPath; # Pass the path as an environment variable
              DWIM_TOOL = dwimToolPath; # Pass the path as an environment variable
              # This would involve invoking DWIM, or other task generators based on the plan.
              # For now, a placeholder.
            } ''
            mkdir -p $out
            echo "{ \"actionPlan\": \"$ACTION_PLAN\", \"generatedTasks\": [ \"dwim-task-1\" ], \"nextState\": \"updated\", \"dwimToolUsed\": \"$DWIM_TOOL\" }" > $out/new-state.json
          '';
        checks.healthcheck = healthcheckData;

        packages.typeReport = pkgs.writeText "act-type-report.json" (builtins.toJSON {
          inputs = {
            dwimFlake = {
              lib = {
                type = "attrset";
                attrs = {
                  "${system}" = {
                    type = "attrset";
                    attrs = {
                      dwim = {
                        type = "any";
                      };
                    };
                  };
                };
              };
            };
          };
        });

        # Add a new package for testing with dummy inputs
        packages.testOutput = self.packages.${system}.default {
          actionPlan = "dummy-action-plan";
          dwimFlake = { lib = { ${system} = { dwim = "/nix/store/dummy-dwim"; }; }; };
        };
      });
}
