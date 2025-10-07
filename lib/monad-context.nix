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
    createDerivationFile = taskName: derivationCode: derivationType:
      if derivationType == "generate-lean4" then
        buildLean4Derivation taskName derivationCode
      else if derivationType == "generate-rust" then
        buildRustDerivation taskName derivationCode
      else if derivationType == "generate-minizinc" then # Assuming we'll have a generate-minizinc type
        buildMiniZincDerivation taskName derivationCode "" # Need to pass dznCode here later
      else
        buildGenericDerivation taskName derivationCode;

    buildLean4Derivation = taskName: lean4Code:
      pkgs.stdenv.mkDerivation {
        name = "lean4-${taskName}";
        buildInputs = [ pkgs.lean ]; # Assuming pkgs.lean exists
        buildCommand = ''
          mkdir -p $out/src
          echo "${lean4Code}" > $out/src/${taskName}.lean
          # Add Lean4 build commands here
        '';
      };

    buildRustDerivation = taskName: rustCode:
      pkgs.stdenv.mkDerivation {
        name = "rust-${taskName}";
        buildInputs = [ pkgs.rustc pkgs.cargo ];
        buildCommand = ''
          mkdir -p $out/src
          echo "${rustCode}" > $out/src/${taskName}.rs
          # Add Rust build commands here
        '';
      };

    buildMiniZincDerivation = taskName: mznCode: dznCode:
      pkgs.stdenv.mkDerivation {
        name = "minizinc-${taskName}";
        buildInputs = [ pkgs.minizinc ];
        buildCommand = ''
          mkdir -p $out/src
          echo "${mznCode}" > $out/src/${taskName}.mzn
          echo "${dznCode}" > $out/src/${taskName}.dzn
          # Add MiniZinc run commands here
        '';
      };

    buildGenericDerivation = taskName: code:
      pkgs.stdenv.mkDerivation {
        name = "generic-${taskName}";
        buildCommand = ''
          mkdir -p $out/src
          echo "${code}" > $out/src/${taskName}.nix
        '';
      };

    # Function to process a single task
    processTask = task:
      let
        geminiResponse = callGemini task.gemini_prompt;
        derivationPath = createDerivationFile task.name geminiResponse.derivationCode task.derivation_type;
      in
      derivationPath; # Returns the path to the generated derivation

  };

in makeContext
