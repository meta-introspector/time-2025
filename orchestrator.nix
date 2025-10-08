{ pkgs, lib, mycologyWorkflow, nixpkgs, nixIntrospector, dataSources, sopsSecretsPath, ... }:

let
  # Import necessary modules
  makeContext = import ./lib/monad-context.nix { inherit pkgs lib; };
  allTasks = makeContext.generateTasks; # Get all tasks from the task generator

  # A simple default vial flake for testing
  defaultVial = pkgs.nix-build {
    name = "default-vial";
    builder = pkgs.writeShellScript "builder" ''
      mkdir -p $out/flake
      cat > $out/flake/flake.nix << EOF
      {
        description = "Default vial flake.";
        outputs = { self, ... }: {
          lib.getPrompt = { pkgs }: "Default prompt from orchestrator's default vial.";
        };
      }
      EOF
    '';
  };

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

      # Invoke mycologyWorkflow with the default vial
      fruitingBody = mycologyWorkflow.outputs.default {
        inherit nixpkgs dataSources;
        flake-utils = nixIntrospector;
        vial = defaultVial;
        mycologyContext = { inherit sopsSecretsPath; };
      };
    in
    # In a real eternal loop, this would trigger the next iteration
    # For now, we just return the new state after one task
    fruitingBody;

in
orchestrate getGlobalState
