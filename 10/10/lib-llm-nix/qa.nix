{ pkgs, lib }:

let
  # Import the lib-llm-nix library
  llmTasksLib = import ./lib {
    inherit lib pkgs;
    flakeSources = [ "github:example/dummy-flake?ref=main" ]; # Use a dummy flake source for QA
    inputFlakes = [ "github:example/dummy-input?ref=main" ];
    processFlakes = [ "github:example/dummy-process?ref=main" ];
    outputFlakes = [ "github:example/dummy-output?ref=main" ];
  };

  # Define a single dummy task for testing
  dummyTask = builtins.head llmTasksLib;

  # QA checks
  qaChecks = {
    # Check if the dummyTask has the expected attributes
    hasExpectedAttributes = pkgs.lib.assertMsg
      (builtins.hasAttr "stableId" dummyTask &&
       builtins.hasAttr "plan" dummyTask &&
       builtins.hasAttr "commit" dummyTask &&
       builtins.hasAttr "run" dummyTask &&
       builtins.hasAttr "eval" dummyTask)
      "dummyTask does not have all expected attributes (stableId, plan, commit, run, eval).";

    # Check if derivations are actually derivations (i.e., not null or other types)
    planIsDerivation = pkgs.lib.assertMsg
      (pkgs.lib.isDerivation dummyTask.plan)
      "dummyTask.plan is not a derivation.";

    commitIsDerivation = pkgs.lib.assertMsg
      (pkgs.lib.isDerivation dummyTask.commit)
      "dummyTask.commit is not a derivation.";

    runIsDerivation = pkgs.lib.assertMsg
      (pkgs.lib.isDerivation dummyTask.run)
      "dummyTask.run is not a derivation.";

    evalIsDerivation = pkgs.lib.assertMsg
      (pkgs.lib.isDerivation dummyTask.eval)
      "dummyTask.eval is not a derivation.";

    # Check if the build commands for plan and eval derivations are set (they should be scripts)
    planHasBuildCommand = pkgs.lib.assertMsg
      (builtins.isString dummyTask.plan.buildCommand && dummyTask.plan.buildCommand != "")
      "dummyTask.plan.buildCommand is not a non-empty string.";

    evalHasBuildCommand = pkgs.lib.assertMsg
      (builtins.isString dummyTask.eval.buildCommand && dummyTask.eval.buildCommand != "")
      "dummyTask.eval.buildCommand is not a non-empty string.";

    # Basic check for the content of the generated flake template (string, not empty)
    generatedFlakeTemplateIsString = pkgs.lib.assertMsg
      (builtins.isString (import ./lib/flake-template-generator.nix {
        inherit lib pkgs;
        flakeSource = "github:example/dummy-flake?ref=main";
        inputFlakes = [ "github:example/dummy-input?ref=main" ];
        processFlakes = [ "github:example/dummy-process?ref=main" ];
        outputFlakes = [ "github:example/dummy-output?ref=main" ];
      }))
      "flake-template-generator.nix does not return a string.";

    generatedFlakeTemplateIsNotEmpty = pkgs.lib.assertMsg
      ((import ./lib/flake-template-generator.nix {
        inherit lib pkgs;
        flakeSource = "github:example/dummy-flake?ref=main";
        inputFlakes = [ "github:example/dummy-input?ref=main" ];
        processFlakes = [ "github:example/dummy-process?ref=main" ];
        outputFlakes = [ "github:example/dummy-output?ref=main" ];
      }) != "")
      "flake-template-generator.nix returns an empty string.";

    # Check if the shell scripts are readable (exist and are strings)
    llmReviewScriptExists = pkgs.lib.assertMsg
      (builtins.isString (builtins.readFile ./lib/llm-review-script.sh))
      "llm-review-script.sh is not readable or does not exist.";

    commitScriptExists = pkgs.lib.assertMsg
      (builtins.isString (builtins.readFile ./lib/commit-script.sh))
      "commit-script.sh is not readable or does not exist.";

    runScriptExists = pkgs.lib.assertMsg
      (builtins.isString (builtins.readFile ./lib/run-script.sh))
      "run-script.sh is not readable or does not exist.";

    evalScriptExists = pkgs.lib.assertMsg
      (builtins.isString (builtins.readFile ./lib/eval-script.sh))
      "eval-script.sh is not readable or does not exist.";
  };
in
  qaChecks
