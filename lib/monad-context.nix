{ pkgs, lib, ... }:

let
  # The context monad constructor
  makeContext = { llmProviders, ... } @ args: rec {
    inherit llmProviders; # Make llmProviders available in this scope
    # Functions that operate within this context
    generateTasks = import ../lib/task-generator.nix { inherit lib pkgs; };
    derivationSpokes = import ../lib/derivation-spokes.nix { inherit pkgs lib; };

  usageTracking = import ./llm/usage-tracking.nix { inherit lib; };



    # Generalized function to interact with LLMs
    callLLM = llmProviderName: prompt:
      let
        llmModule = llmProviders.${llmProviderName} or (throw "Unknown LLM provider: ${llmProviderName}");
      in
      llmModule.callApi prompt;

    # TODO: Refactor this to be more modular, perhaps using an attribute set to map derivation types to functions.
    # Function to create a Nix derivation file
    createDerivationFile = taskName: derivationCode: derivationType: llmProvider:
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
      else if derivationType == "generate-llm-code" then
        derivationSpokes.mkLLMCodeSpoke taskName llmProvider derivationCode
      else if derivationType == "generate-bootstrap-plan" then
        derivationSpokes.mkBootstrapSpoke taskName derivationCode
      else
        derivationSpokes.mkGenericSpoke taskName derivationCode;

    # Function to process a single task
    processTask = task:
      let
        # Get the specific LLM module
        llmModule = llmProviders.${task.llm_provider} or (throw "Unknown LLM provider: ${task.llm_provider}");

        # Collect current quota information
        currentQuota = llmModule.getQuota;

        # Prepare data for MiniZinc solver (estimated usage, current quota, task priority, etc.)
        mznModel = builtins.readFile ../10/04/bootstrap/llm-optimizer.mzn;
        dznData = ''
          num_llm_providers = 5; % Gemini, Groq, AmazonQ, GitHub Copilot, OpenAI Codex
          num_tasks = 1; % Processing one task at a time for now

          total_requests = [${toString llmProviders.gemini.getQuota.totalRequests}, ${toString llmProviders.groq.getQuota.totalRequests}, ${toString llmProviders.amazonq.getQuota.totalRequests}, ${toString llmProviders.github-copilot.getQuota.totalRequests}, ${toString llmProviders.openai-codex.getQuota.totalRequests}];
          remaining_requests = [${toString llmProviders.gemini.getQuota.remainingRequests}, ${toString llmProviders.groq.getQuota.remainingRequests}, ${toString llmProviders.amazonq.getQuota.remainingRequests}, ${toString llmProviders.github-copilot.getQuota.remainingRequests}, ${toString llmProviders.openai-codex.getQuota.remainingRequests}];
          requests_per_minute = [${toString llmProviders.gemini.getQuota.requestsPerMinute}, ${toString llmProviders.groq.getQuota.requestsPerMinute}, ${toString llmProviders.amazonq.getQuota.requestsPerMinute}, ${toString llmProviders.github-copilot.getQuota.requestsPerMinute}, ${toString llmProviders.openai-codex.getQuota.requestsPerMinute}];
          requests_per_hour = [${toString llmProviders.gemini.getQuota.requestsPerHour}, ${toString llmProviders.groq.getQuota.requestsPerHour}, ${toString llmProviders.amazonq.getQuota.requestsPerHour}, ${toString llmProviders.github-copilot.getQuota.requestsPerHour}, ${toString llmProviders.openai-codex.getQuota.requestsPerHour}];
          requests_per_day = [${toString llmProviders.gemini.getQuota.requestsPerDay}, ${toString llmProviders.groq.getQuota.requestsPerDay}, ${toString llmProviders.amazonq.getQuota.requestsPerDay}, ${toString llmProviders.github-copilot.getQuota.requestsPerDay}, ${toString llmProviders.openai-codex.getQuota.requestsPerDay}];
          requests_per_week = [${toString llmProviders.gemini.getQuota.requestsPerWeek}, ${toString llmProviders.groq.getQuota.requestsPerWeek}, ${toString llmProviders.amazonq.getQuota.requestsPerWeek}, ${toString llmProviders.github-copilot.getQuota.requestsPerWeek}, ${toString llmProviders.openai-codex.getQuota.requestsPerWeek}];

          total_tokens = [${toString llmProviders.gemini.getQuota.totalTokens}, ${toString llmProviders.groq.getQuota.totalTokens}, ${toString llmProviders.amazonq.getQuota.totalTokens}, ${toString llmProviders.github-copilot.getQuota.totalTokens}, ${toString llmProviders.openai-codex.getQuota.totalTokens}];
          remaining_tokens = [${toString llmProviders.gemini.getQuota.remainingTokens}, ${toString llmProviders.groq.getQuota.remainingTokens}, ${toString llmProviders.amazonq.getQuota.remainingTokens}, ${toString llmProviders.github-copilot.getQuota.remainingTokens}, ${toString llmProviders.openai-codex.getQuota.remainingTokens}];
          tokens_per_minute = [${toString llmProviders.gemini.getQuota.tokensPerMinute}, ${toString llmProviders.groq.getQuota.tokensPerMinute}, ${toString llmProviders.amazonq.getQuota.tokensPerMinute}, ${toString llmProviders.github-copilot.getQuota.tokensPerMinute}, ${toString llmProviders.openai-codex.getQuota.tokensPerMinute}];
          tokens_per_hour = [${toString llmProviders.gemini.getQuota.tokensPerHour}, ${toString llmProviders.groq.getQuota.tokensPerHour}, ${toString llmProviders.amazonq.getQuota.tokensPerHour}, ${toString llmProviders.github-copilot.getQuota.tokensPerHour}, ${toString llmProviders.openai-codex.getQuota.tokensPerHour}];
          tokens_per_day = [${toString llmProviders.gemini.getQuota.tokensPerDay}, ${toString llmProviders.groq.getQuota.tokensPerDay}, ${toString llmProviders.amazonq.getQuota.tokensPerDay}, ${toString llmProviders.github-copilot.getQuota.tokensPerDay}, ${toString llmProviders.openai-codex.getQuota.tokensPerDay}];
          tokens_per_week = [${toString llmProviders.gemini.getQuota.tokensPerWeek}, ${toString llmProviders.groq.getQuota.tokensPerWeek}, ${toString llmProviders.amazonq.getQuota.tokensPerWeek}, ${toString llmProviders.github-copilot.getQuota.tokensPerWeek}, ${toString llmProviders.openai-codex.getQuota.tokensPerWeek}];

          estimated_task_requests = [${toString task.estimatedUsage.estimatedRequests}];
          estimated_task_tokens = [${toString task.estimatedUsage.estimatedTokens}];
          task_priority = [${toString (task.priority or 1)}]; % Assuming tasks have a priority attribute, default to 1
        '';

        # Run the MiniZinc solver
        solverResultDerivation = derivationSpokes.mkMiniZincOptimizationSpoke "llm-task-optimizer" mznModel dznData;
        solverOutput = builtins.readFile solverResultDerivation;

        # Parse solver output to determine decision
        # FIXME: Implement robust parsing of MiniZinc output
        solverDecision =
          if lib.strings.hasSubstr "assign_llm = [0]" solverOutput then
            { proceed = false; } # Task not assigned to any LLM
          else
            { proceed = true;
              assignedLLMIndex = lib.strings.substring (lib.strings.indexOf "assign_llm = [" solverOutput + 13) 1 solverOutput;
            };

        llmResponse =
          if solverDecision.proceed then
            callLLM task.llm_provider task.gemini_prompt
          else
            throw "MiniZinc solver decided not to proceed with task: ${task.name}";

        # Measure actual usage after the LLM call
        actualUsage = llmModule.measureUsage task.gemini_prompt llmResponse;

        derivationPath = createDerivationFile task.name llmResponse.derivationCode task.derivation_type task.llm_provider;
      in
      derivationPath; # Returns the path to the generated derivation

  };

in makeContext
