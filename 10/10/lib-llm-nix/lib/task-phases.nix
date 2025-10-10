{ lib, pkgs, flakeSource, inputFlakes, processFlakes, outputFlakes }:

let
  # Import the flake template generator
  generateFlakeTemplateString = import ./flake-template-generator.nix {
    inherit lib pkgs flakeSource inputFlakes processFlakes outputFlakes;
  };

  # Write the generated flake template string to a temporary file for the scripts to use
  initialDerivedFlakeContentFile = pkgs.writeText "initial-derived-flake.nix" generateFlakeTemplateString;

  # Import the shell scripts
  llmReviewScript = pkgs.writeScript "llm-review-script" (builtins.readFile ./llm-review-script.sh);
  commitScript = pkgs.writeScript "commit-script" (builtins.readFile ./commit-script.sh);
  runScript = pkgs.writeScript "run-script" (builtins.readFile ./run-script.sh);
  evalScript = pkgs.writeScript "eval-script" (builtins.readFile ./eval-script.sh);

  # Plan Phase: Generate a script that creates and builds the derived flake, including LLM review
  planDerivation = pkgs.runCommand "plan-${lib.strings.sanitizeDerivationName flakeSource}" {
    nativeBuildInputs = [ pkgs.gemini-cli ];
  } "${llmReviewScript} ${flakeSource} ${initialDerivedFlakeContentFile} ${pkgs.gemini-cli}/bin/gemini";

  # Commit Phase: Displays the generated flake.nix for the derived flake
  commitDerivation = pkgs.runCommand "commit-${lib.strings.sanitizeDerivationName flakeSource}" {} "${commitScript} ${flakeSource} ${planDerivation}";

  # Run Phase: Execute the build command from the plan
  runDerivation = pkgs.runCommand "run-${lib.strings.sanitizeDerivationName flakeSource}" {} "${runScript} ${flakeSource} ${planDerivation}";

  # Eval Phase: Builds and tests the derived flake directly
  evalDerivation = pkgs.runCommand "eval-${lib.strings.sanitizeDerivationName flakeSource}" {} "${evalScript} ${flakeSource} ${initialDerivedFlakeContentFile}";

in
{
  inherit planDerivation commitDerivation runDerivation evalDerivation;
}