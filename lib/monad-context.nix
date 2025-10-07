{ pkgs, lib, geminiApi, ... }:

let
  # The context monad constructor
  makeContext = rec {
    # Functions that operate within this context
    generateTasks = import ../lib/task-generator.nix { inherit lib; };
    derivationSpokes = import ../lib/derivation-spokes.nix { inherit pkgs lib; };

    # Function to interact with Gemini (placeholder for now)
    callGemini = prompt: geminiApi.generateCode {
      inherit prompt;
      # Add other parameters as needed for Gemini API call
      # For now, we'll just pass the prompt
    };

    # Function to create a Nix derivation file
    createDerivationFile = taskName: derivationCode: derivationType:
      if derivationType == "generate-lean4" then
        derivationSpokes.mkLean4Spoke taskName derivationCode
      else if derivationType == "generate-rust" then
        derivationSpokes.mkRustSpoke taskName derivationCode
      else if derivationType == "generate-minizinc" then # Assuming we'll have a generate-minizinc type
        derivationSpokes.mkMiniZincSpoke taskName derivationCode "" # Need to pass dznCode here later
      else if derivationType == "generate-tiktok" then
        derivationSpokes.mkTikTokSpoke taskName derivationCode "0" # Placeholder OEIS number for now
      else
        derivationSpokes.mkGenericSpoke taskName derivationCode;

    # Function to process a single task
    processTask = task:
      let
        geminiResponse = callGemini task.gemini_prompt;
        derivationPath = createDerivationFile task.name geminiResponse.derivationCode task.derivation_type;
      in
      derivationPath; # Returns the path to the generated derivation

  };

in makeContext
