{ pkgs, lib, mycologyWorkflow, nixpkgs, nixIntrospector, dataSources, sopsSecretsPath, zosSporeVial, nixToPoemVial, readMdVial, readRsVial, targetFilePath ? null, ... }:

let
  # Import necessary modules
  makeContext = import ./lib/monad-context.nix { inherit pkgs lib; };
  allTasks = makeContext.generateTasks; # Get all tasks from the task generator

  # Read the list of Nix files from index.nix.txt
  nixFiles = pkgs.lib.splitString "\n" (builtins.readFile ./index.nix.txt);

  # Function to select the appropriate vial flake based on file extension
  selectVialFlake = filePath:
    let
      extension = pkgs.lib.last (pkgs.lib.splitString "." filePath);
    in
    if extension == "nix" then nixToPoemVial
    else if extension == "md" then readMdVial
    else if extension == "rs" then readRsVial
    else zosSporeVial; # Default vial

  # The main orchestration logic, now a function that returns the fruitingBody
  runOrchestration =
    let
      # Function to get the current global state (placeholder for now)
      # In a real system, this would read from a persistent store
      getGlobalState = { 
        # Dummy global state for now
        currentLlmUsage = {
          gemini = { requests = 100; tokens = 10000; };
          groq = { requests = 50; tokens = 5000; };
          # ... other LLMs
        };
        # ... other global state variables
      };

      # The main orchestration loop
      orchestrate = globalState:
        let
          # Prepare data for the MiniZinc solver
          # This will involve iterating through allTasks and current LLM quotas
          # For now, we'll use a simplified approach and assume the solver
          # is called within processTask for each task.
          # FIXME: The MiniZinc solver should be called once with all tasks
          # to determine the globally optimal next task.

          # Find the best next task (simplified for now)
          # This would ideally come from the MiniZinc solver's output
          bestNextTask = lib.head allTasks; # Just pick the first task for now

          # Process the best next task
          newGlobalState = makeContext.processTask bestNextTask;

          # Get the first valid file path from the list
          firstValidFilePath = lib.head (lib.filter (f: f != "") nixFiles);

          # Determine the file path to process
          fileToProcess = if targetFilePath != null then targetFilePath else firstValidFilePath;

          # Select the appropriate vial flake for the file to process
          selectedVialFlake = if fileToProcess != null then selectVialFlake fileToProcess else zosSporeVial; # Fallback

          # Invoke mycologyWorkflow with the file to process and the selected vial flake
          fruitingBody = if fileToProcess != null then mycologyWorkflow.outputs.default {
            inherit nixpkgs dataSources;
            flake-utils = nixIntrospector;
            vial = selectedVialFlake; # Pass the selected vial flake
            filePath = fileToProcess; # Pass the file path
            mycologyContext = { inherit sopsSecretsPath; };
          } else null; # Handle case where no valid file is found
        in
        # For now, let's just return the fruitingBody
        fruitingBody;
    in
    orchestrate getGlobalState; # Call orchestrate with initial global state

in
{
  apps.default = {
    type = "app";
    program = pkgs.writeShellScript "run-orchestrator" ''
      echo "--- Orchestrator Running ---"
      # The runOrchestration function returns a derivation, so we build it
      FRUITING_BODY_PATH=$(nix build --no-link --print-out-paths ${runOrchestration})
      cat "$FRUITING_BODY_PATH" # Print the content of the fruiting body
      echo "--- Orchestrator Finished ---"
    '';
  };
}