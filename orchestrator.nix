{ pkgs, lib, mycologyWorkflow, nixpkgs, nixIntrospector, dataSources, sopsSecretsPath, zosSporeVial, ... }:

let
  # Import necessary modules
  makeContext = import ./lib/monad-context.nix { inherit pkgs lib; };
  allTasks = makeContext.generateTasks; # Get all tasks from the task generator

  # Read the list of Nix files from index.nix.txt
  nixFiles = pkgs.lib.splitString "\n" (builtins.readFile ./index.nix.txt);

  createVialForNixFile = nixFile:
    pkgs.nix-build {
      name = "vial-for-${(pkgs.lib.replaceStrings ["/"] ["-"] nixFile)}";
      builder = pkgs.writeShellScript "builder" ''
        mkdir -p $out/flake
        cat > $out/flake/flake.nix << EOF
        {
          description = "Vial for Nix file: ${nixFile}.";
          outputs = { self, ... }: {
            lib.getPrompt = { pkgs }: "Inspect the Nix file at path: ${nixFile}. Provide a summary of its purpose, key functions, and any potential areas for improvement or optimization.";
          };
        }
        EOF
      '';
    };

  vials = lib.map createVialForNixFile nixFiles;

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

      # Invoke mycologyWorkflow with the first valid vial
      fruitingBody = if firstValidVial != null then mycologyWorkflow.outputs.default {
        inherit nixpkgs dataSources;
        flake-utils = nixIntrospector;
        vial = firstValidVial;
        mycologyContext = { inherit sopsSecretsPath; };
      } else null; # Handle case where no valid vial is found
    in
    # For now, let's just return the fruitingBody
    fruitingBody;

in
orchestrate getGlobalState
