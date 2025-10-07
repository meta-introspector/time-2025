{ pkgs, lib, geminiApi, ... }:

let
  # The context monad constructor
  makeContext = rec {
    # Functions that operate within this context
    generateTasks = import ../lib/task-generator.nix { inherit lib pkgs; };
    derivationSpokes = import ../lib/derivation-spokes.nix { inherit pkgs lib; };

    # FIXME: Implement the actual Gemini API call.
    # Function to interact with Gemini (placeholder for now)
    callGemini = prompt: geminiApi.generateCode {
      inherit prompt;
      # Add other parameters as needed for Gemini API call
      # For now, we'll just pass the prompt
    };

    # TODO: Refactor this to be more modular, perhaps using an attribute set to map derivation types to functions.
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
      else if derivationType == "deploy-aws" then
        derivationSpokes.mkAwsSpoke taskName derivationCode
      else if derivationType == "deploy-gcp" then
        derivationSpokes.mkGcpSpoke taskName derivationCode
      else if derivationType == "deploy-azure" then
        derivationSpokes.mkAzureSpoke taskName derivationCode
      else if derivationType == "deploy-oracle-cloud" then
        derivationSpokes.mkOracleCloudSpoke taskName derivationCode
      else if derivationType == "archive-archive-org" then
        derivationSpokes.mkArchiveOrgSpoke taskName derivationCode
      else if derivationType == "deploy-hugging-face" then
        derivationSpokes.mkHuggingFaceSpoke taskName derivationCode
      else if derivationType == "host-sdf-org" then
        derivationSpokes.mkSdfOrgSpoke taskName derivationCode
      else if derivationType == "store-filecoin" then
        derivationSpokes.mkFilecoinSpoke taskName derivationCode
      else if derivationType == "store-other-storage-coin" then
        derivationSpokes.mkOtherStorageCoinSpoke taskName derivationCode
      else if derivationType == "publish-dockerhub" then
        derivationSpokes.mkDockerHubSpoke taskName derivationCode
      else if derivationType == "create-github-release" then
        derivationSpokes.mkGithubReleaseSpoke taskName derivationCode
      else if derivationType == "trigger-github-actions" then
        derivationSpokes.mkGithubActionsSpoke taskName derivationCode
      else if derivationType == "build-aws-codebuild" then
        derivationSpokes.mkAwsCodeBuildSpoke taskName derivationCode
      else if derivationType == "schedule-self-hosted-hydra" then
        derivationSpokes.mkSelfHostedNixBuildHydraSpoke taskName derivationCode
      else if derivationType == "refine-minizinc" then
        derivationSpokes.mkMiniZincSpoke taskName derivationCode "" # This will be the refined MiniZinc model
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
