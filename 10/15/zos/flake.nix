{
  description = "The Zero-One-System (ZOS) flake: a self-evolving, OODA-loop-driven meta-orchestrator.";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
    flake-utils.url = "github:meta-introspector/flake-utils?ref=feature/CRQ-016-nixify";

    dwimFlake.url = "github:meta-introspector/time-2025?ref=feature/aimyc-003-cultivation&dir=10/15/dwim";
    workflowTasksFlake.url = "github:meta-introspector/time-2025?ref=feature/aimyc-003-cultivation&dir=10/15/workflow-tasks";
    llmGeneratorFlake.url = "github:meta-introspector/time-2025?ref=feature/aimyc-003-cultivation&dir=10/14";
    metaOrchestratorFlake.url = "github:meta-introspector/time-2025?ref=feature/aimyc-003-cultivation&dir=10/15/meta-orchestrator";
    observeFlake = {
      url = "github:meta-introspector/time-2025?ref=feature/aimyc-003-cultivation&dir=10/15/zos/tasks/observe";
      # inputs.currentState.url = initialState;
    };
    orientFlake.url = "github:meta-introspector/time-2025?ref=feature/aimyc-003-cultivation&dir=10/15/zos/tasks/orient";
    decideFlake.url = "github:meta-introspector/time-2025?ref=feature/aimyc-003-cultivation&dir=10/15/zos/tasks/decide";
    actFlake.url = "github:meta-introspector/time-2025?ref=feature/aimyc-003-cultivation&dir=10/15/zos/tasks/act";
    runZosTasksFlake.url = "github:meta-introspector/time-2025?ref=feature/aimyc-003-cultivation&dir=10/15/zos/tasks/run-zos-tasks";
  };

  outputs = { self, nixpkgs, flake-utils, dwimFlake, workflowTasksFlake, llmGeneratorFlake, metaOrchestratorFlake, observeFlake, orientFlake, decideFlake, actFlake, runZosTasksFlake, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        lib = pkgs.lib;

        # The OODA loop function
        # Takes a 'state' (a derivation representing the current system state)
        # and returns a new 'state' (a derivation representing the next system state)
        # This is where the Observe, Orient, Decide, Act logic will reside.
        ooda = currentState:
          let
            # observationReport = observeFlake.packages.${system}.default { inherit currentState; };
            # Observe
            observationReport = observeFlake.packages.${system}.default { inherit currentState; };
            # Orient
            #orientationDecision = orientFlake.packages.${system}.default {
            #  inherit observationReport llmGeneratorFlake;
            #};
            # Decide
            #actionPlan = decideFlake.packages.${system}.default { inherit orientationDecision; };
            # Act
            nextState = actFlake.packages.${system}.default {
              actionPlan = "actionPlan";
              dwimFlake = dwimFlake;
            };
          in
          nextState;

        # Fixed-point combinator for iterative OODA application
        # This is a conceptual placeholder. Actual implementation will be complex.
        # It would involve a recursive function that applies ooda until a condition is met.
        # For now, let's just define an initial state and one application.
        initialState = pkgs.runCommand "initial-system-state"
          {
            repoSource = self; # The ZOS flake's self input, which is the repo root
            buildInputs = [ pkgs.nix ]; # For nix-hash
          } ''
          echo "{ \"repoHash\": \"$(nix-hash --flat --base32 $repoSource)\", \"timestamp\": \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\", \"projects\": [], \"tasks\": [] }" > $out
        '';

        # One application of the OODA loop
        firstOodaIteration = ooda initialState;

        # The 'run' command to execute generated tasks (placeholder)
        runZosTasks = runZosTasksFlake.packages.${system}.default;

      in
      {
        packages = {
          # Expose the OODA loop's output
          oodaState = firstOodaIteration;
          run = runZosTasks;
          bootstrap.zos = pkgs.runCommand "zos-bootstrap"
            {
              inherit firstOodaIteration;
              # This bootstrap target will trigger the first OODA iteration
            } ''
            echo "ZOS bootstrap complete. First OODA iteration result: $firstOodaIteration" > $out
          '';
        };
      } // {
        defaultPackage = self.packages.${system}.bootstrap.zos;
      }
    );
}
