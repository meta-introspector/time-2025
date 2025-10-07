{ pkgs, lib, ... }:

let
  # The context monad constructor
  makeContext = rec {
    # Functions that operate within this context
    generateTasks = import ../lib/task-generator.nix { inherit lib pkgs; };
    derivationSpokes = import ../lib/derivation-spokes.nix { inherit pkgs lib; };

  usageTracking = import ./llm/usage-tracking.nix { inherit lib; };

    # Import LLM integration modules
    geminiLLM = import ../lib/llm/gemini.nix { inherit pkgs lib; };
    groqLLM = import ../lib/llm/groq.nix { inherit pkgs lib; };
    amazonqLLM = import ../lib/llm/amazonq.nix { inherit pkgs lib; };
    githubCopilotLLM = import ../lib/llm/github-copilot.nix { inherit pkgs lib; };
    openaiCodexLLM = import ../lib/llm/openai-codex.nix { inherit pkgs lib; };

    # Generalized function to interact with LLMs
    callLLM = llmProvider: prompt:
      if llmProvider == "gemini" then geminiLLM.callApi prompt
      else if llmProvider == "groq" then groqLLM.callApi prompt
      else if llmProvider == "amazonq" then amazonqLLM.callApi prompt
      else if llmProvider == "github-copilot" then githubCopilotLLM.callApi prompt
      else if llmProvider == "openai-codex" then openaiCodexLLM.callApi prompt
      else throw "Unknown LLM provider: ${llmProvider}";

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
      else if derivationType == "generate-llm-code" then
        derivationSpokes.mkLLMCodeSpoke taskName task.llm_provider derivationCode
      else if derivationType == "generate-bootstrap-plan" then
        derivationSpokes.mkBootstrapSpoke taskName derivationCode
      else
        derivationSpokes.mkGenericSpoke taskName derivationCode;

    # Function to process a single task
    processTask = task:
      let
        # Get the specific LLM module
        llmModule =
          if task.llm_provider == "gemini" then geminiLLM
          else if task.llm_provider == "groq" then groqLLM
          else if task.llm_provider == "amazonq" then amazonqLLM
          else if task.llm_provider == "github-copilot" then githubCopilotLLM
          else if task.llm_provider == "openai-codex" then openaiCodexLLM
          else throw "Unknown LLM provider: ${task.llm_provider}";

        # Collect current quota information
        currentQuota = llmModule.getQuota;

        # Prepare data for MiniZinc solver (estimated usage, current quota, task priority, etc.)
        mznModel = builtins.readFile ../10/04/bootstrap/llm-optimizer.mzn;
        dznData = ''
          num_llm_providers = 5; % Gemini, Groq, AmazonQ, GitHub Copilot, OpenAI Codex
          num_tasks = 1; % Processing one task at a time for now

          total_requests = [${toString geminiLLM.getQuota.totalRequests}, ${toString groqLLM.getQuota.totalRequests}, ${toString amazonqLLM.getQuota.totalRequests}, ${toString githubCopilotLLM.getQuota.totalRequests}, ${toString openaiCodexLLM.getQuota.totalRequests}];
          remaining_requests = [${toString geminiLLM.getQuota.remainingRequests}, ${toString groqLLM.getQuota.remainingRequests}, ${toString amazonqLLM.getQuota.remainingRequests}, ${toString githubCopilotLLM.getQuota.remainingRequests}, ${toString openaiCodexLLM.getQuota.remainingRequests}];
          requests_per_minute = [${toString geminiLLM.getQuota.requestsPerMinute}, ${toString groqLLM.getQuota.requestsPerMinute}, ${toString amazonqLLM.getQuota.requestsPerMinute}, ${toString githubCopilotLLM.getQuota.requestsPerMinute}, ${toString openaiCodexLLM.getQuota.requestsPerMinute}];
          requests_per_hour = [${toString geminiLLM.getQuota.requestsPerHour}, ${toString groqLLM.getQuota.requestsPerHour}, ${toString amazonqLLM.getQuota.requestsPerHour}, ${toString githubCopilotLLM.getQuota.requestsPerHour}, ${toString openaiCodexLLM.getQuota.requestsPerHour}];
          requests_per_day = [${toString geminiLLM.getQuota.requestsPerDay}, ${toString groqLLM.getQuota.requestsPerDay}, ${toString amazonqLLM.getQuota.requestsPerDay}, ${toString githubCopilotLLM.getQuota.requestsPerDay}, ${toString openaiCodexLLM.getQuota.requestsPerDay}];
          requests_per_week = [${toString geminiLLM.getQuota.requestsPerWeek}, ${toString groqLLM.getQuota.requestsPerWeek}, ${toString amazonqLLM.getQuota.requestsPerWeek}, ${toString githubCopilotLLM.getQuota.requestsPerWeek}, ${toString openaiCodexLLM.getQuota.requestsPerWeek}];

          total_tokens = [${toString geminiLLM.getQuota.totalTokens}, ${toString groqLLM.getQuota.totalTokens}, ${toString amazonqLLM.getQuota.totalTokens}, ${toString githubCopilotLLM.getQuota.totalTokens}, ${toString openaiCodexLLM.getQuota.totalTokens}];
          remaining_tokens = [${toString geminiLLM.getQuota.remainingTokens}, ${toString groqLLM.getQuota.remainingTokens}, ${toString amazonqLLM.getQuota.remainingTokens}, ${toString githubCopilotLLM.getQuota.remainingTokens}, ${toString openaiCodexLLM.getQuota.remainingTokens}];
          tokens_per_minute = [${toString geminiLLM.getQuota.tokensPerMinute}, ${toString groqLLM.getQuota.tokensPerMinute}, ${toString amazonqLLM.getQuota.tokensPerMinute}, ${toString githubCopilotLLM.getQuota.tokensPerMinute}, ${toString openaiCodexLLM.getQuota.tokensPerMinute}];
          tokens_per_hour = [${toString geminiLLM.getQuota.tokensPerHour}, ${toString groqLLM.getQuota.tokensPerHour}, ${toString amazonqLLM.getQuota.tokensPerHour}, ${toString githubCopilotLLM.getQuota.tokensPerHour}, ${toString openaiCodexLLM.getQuota.tokensPerHour}];
          tokens_per_day = [${toString geminiLLM.getQuota.tokensPerDay}, ${toString groqLLM.getQuota.tokensPerDay}, ${toString amazonqLLM.getQuota.tokensPerDay}, ${toString githubCopilotLLM.getQuota.tokensPerDay}, ${toString openaiCodexLLM.getQuota.tokensPerDay}];
          tokens_per_week = [${toString geminiLLM.getQuota.tokensPerWeek}, ${toString groqLLM.getQuota.tokensPerWeek}, ${toString amazonqLLM.getQuota.tokensPerWeek}, ${toString githubCopilotLLM.getQuota.tokensPerWeek}, ${toString openaiCodexLLM.getQuota.tokensPerWeek}];

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

        derivationPath = createDerivationFile task.name llmResponse.derivationCode task.derivation_type;
      in
      derivationPath; # Returns the path to the generated derivation

  };

in makeContext
