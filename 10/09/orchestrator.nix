{ pkgs, lib, mycologyWorkflow, nixpkgs, nixIntrospector, dataSources, sopsSecretsPath, zosSporeVial, nixToPoemVial, readMdVial, readRsVial, targetFilePath ? null, ... }:

let
  # Import necessary modules
  makeContext = import ./lib/monad-context.nix { inherit pkgs lib; };
  # allTasks = makeContext.generateTasks; # Get all tasks from the task generator

  # Import the nix-task mkTask function
  inherit (mycologyWorkflow.lib) mkTask;

  # Import the gemini-cli package
  inherit (pkgs) gemini-cli;

  # Generate 100 LLM tasks
  allTasks = import ./llm-tasks.nix {
    inherit lib pkgs mkTask; flakeSources = [ "github:meta-introspector/time-2025?ref=feature/lattice-30030-homedir" ];
    inputFlakes = [ "github:meta-introspector/time-2025?ref=feature/lattice-30030-homedir&dir=10/10/llm-inputs" ];
    processFlakes = [ "github:meta-introspector/time-2025?ref=feature/lattice-30030-homedir&dir=10/10/llm-processes" ];
    outputFlakes = [ "github:meta-introspector/time-2025?ref=feature/lattice-30030-homedir&dir=10/10/llm-outputs" ];
  };

  # Read the list of Nix files from index.nix.txt
  nixFiles = pkgs.lib.splitString "\n" (builtins.readFile ./index.nix.txt);

  # The main orchestration logic, now a function that returns the fruitingBody
  runOrchestration =
    let
      # Process all tasks through their phases
      allPhasedOutputs = lib.flatten (lib.map
        (task:
          [
            task.plan
            task.commit
            task.run
            task.eval
          ]
        )
        allTasks);
    in
    allPhasedOutputs;

in
{
  apps.default = {
    type = "app";
    program = pkgs.writeShellScript "run-orchestrator" ''
      echo "--- Running Orchestration with Phases ---"
      # The runOrchestration function returns a list of derivations, so we build them all
      for PHASE_DERIVATION in ${lib.concatStringsSep " " runOrchestration}; do
        echo "--- Building Phase: $(basename $PHASE_DERIVATION) ---"
        PHASE_OUTPUT_PATH=$(nix build --no-link --print-out-paths $PHASE_DERIVATION)
        echo "--- Phase Output Path: $PHASE_OUTPUT_PATH ---"
        cat "$PHASE_OUTPUT_PATH"
        echo "-----------------------------------------"
      done
      echo "--- Orchestrator Finished ---"
    '';
  };
}
