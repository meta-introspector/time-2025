{ pkgs, lib, geminiApi, ... }:

let
  # The context monad constructor
  makeContext = rec {
    # Functions that operate within this context
    generateTasks = import ../lib/task-generator.nix { inherit lib; };

    # Function to interact with Gemini (placeholder for now)
    callGemini = prompt: geminiApi.generateCode {
      inherit prompt;
      # Add other parameters as needed for Gemini API call
      # For now, we'll just pass the prompt
    };

    # Function to create a Nix derivation file
    createDerivationFile = taskName: derivationCode:
      let
        dir = "./generated-derivations";
        file = "${dir}/${taskName}.nix";
      in
      pkgs.runCommand "write-derivation-${taskName}" {
        buildInputs = [ pkgs.coreutils ];
      }
      ''
        mkdir -p ${dir}
        echo "${derivationCode}" > ${file}
        echo "${file}" > $out
      '';

    # Function to process a single task
    processTask = task:
      let
        geminiResponse = callGemini task.gemini_prompt;
        derivationPath = createDerivationFile task.name geminiResponse.derivationCode;
      in
      derivationPath; # Returns the path to the generated derivation

  };

in makeContext
