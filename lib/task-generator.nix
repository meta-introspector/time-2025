{ lib, pkgs, ... } @ args:

let
  primeMappingConfig = import ./prime-mapping-config.nix { inherit lib; };
  functorMatrix = import ./code-generation/functor-matrix.nix { inherit lib; };
  tiktokConfig = import ./tiktok-config.nix { inherit lib; };
  nix2llm = import ./nix2llm.nix { inherit lib; };
  oeisSolverResult = import ../solvers/run-oeis-solver.nix { inherit lib pkgs; config = { }; }; # Passed empty config
  currentOeisNumber = builtins.readFile oeisSolverResult.solverResult;

  usageTracking = import ./llm/usage-tracking.nix { inherit lib; };

  # TODO: Make the Gemini prompts more sophisticated.
  generateTask = file_path: type: llm_provider:
    let
      prompt = "Create a Nix derivation to ${type} the file ${file_path}.";
    in
    {
      name = "${type}-${(lib.strings.removeSuffix ".nix" (lib.strings.removePrefix "lib/emoji-encoding/" file_path))}";
      inherit file_path type llm_provider;
      derivation_type = type;
      gemini_prompt = prompt;
      estimatedUsage = {
        estimatedTokens = lib.strings.stringLength prompt * 2; # Simple estimation
        estimatedRequests = 1;
      };
    };

  emojiEncodingModules = [
    "lib/emoji-encoding/int.nix"
    "lib/emoji-encoding/string.nix"
    "lib/emoji-encoding/list.nix"
    "lib/emoji-encoding/attrset.nix"
    "lib/emoji-encoding/lambda.nix"
    "lib/emoji-encoding/let-in.nix"
    "lib/emoji-encoding/if-then-else.nix"
  ];

  emojiEncodingTests = [
    "tests/emoji-encoding/int-test.nix"
    "tests/emoji-encoding/string-test.nix"
    "tests/emoji-encoding/list-test.nix"
    "tests/emoji-encoding/attrset-test.nix"
    "tests/emoji-encoding/lambda-test.nix"
    "tests/emoji-encoding/let-in-test.nix"
    "tests/emoji-encoding/if-then-else-test.nix"
  ];

  moduleTasks = lib.map (path: generateTask path "build" "gemini") emojiEncodingModules;
  testTasks = lib.map (path: generateTask path "test" "gemini") emojiEncodingTests;

  lean4Tasks = lib.map
    (concept: {
      name = "lean4-gen-${concept}";
      file_path = "generated/lean4/${concept}.lean";
      derivation_type = "generate-lean4";
      llm_provider = "gemini"; # Added
      gemini_prompt = "Generate Lean4 code for the '${concept}' concept using the functorMatrix.lean4Generators.${concept} function.";
    })
    primeMappingConfig.concepts;

  rustTasks = lib.map
    (concept: {
      name = "rust-gen-${concept}";
      file_path = "generated/rust/${concept}.rs";
      derivation_type = "generate-rust";
      llm_provider = "gemini"; # Added
      gemini_prompt = "Generate Rust code for the '${concept}' concept using the functorMatrix.rustGenerators.${concept} function.";
    })
    primeMappingConfig.concepts;

  tiktokTasks = lib.map
    (concept: {
      name = "tiktok-gen-${concept}";
      file_path = "${tiktokConfig.tiktokOutputPath}/${concept}${tiktokConfig.tiktokScriptExtension}"; # Markdown for TikTok script
      derivation_type = "generate-tiktok";
      llm_provider = "gemini"; # Added
      gemini_prompt = tiktokConfig.generateTiktokPrompt concept currentOeisNumber;
    })
    primeMappingConfig.concepts;

  dockerHubTasks = lib.map
    (concept: {
      name = "dockerhub-publish-${concept}";
      file_path = "generated/dockerhub/${concept}.json"; # Docker image config
      derivation_type = "publish-dockerhub";
      llm_provider = "gemini"; # Added
      gemini_prompt = "Generate DockerHub publishing configuration for the '${concept}' concept.";
    })
    primeMappingConfig.concepts;

  githubReleaseTasks = lib.map
    (concept: {
      name = "github-release-${concept}";
      file_path = "generated/github-release/${concept}.json"; # GitHub Release config
      derivation_type = "create-github-release";
      llm_provider = "gemini"; # Added
      gemini_prompt = "Generate GitHub Release configuration for the '${concept}' concept.";
    })
    primeMappingConfig.concepts;

  githubActionsTasks = lib.map
    (concept: {
      name = "github-actions-${concept}";
      file_path = "generated/github-actions/${concept}.yaml"; # GitHub Actions workflow
      derivation_type = "trigger-github-actions";
      llm_provider = "gemini"; # Added
      gemini_prompt = "Generate GitHub Actions workflow for the '${concept}' concept.";
    })
    primeMappingConfig.concepts;

  awsCodeBuildTasks = lib.map
    (concept: {
      name = "aws-codebuild-${concept}";
      file_path = "generated/aws-codebuild/${concept}.json"; # AWS CodeBuild config
      derivation_type = "build-aws-codebuild";
      llm_provider = "gemini"; # Added
      gemini_prompt = "Generate AWS CodeBuild configuration for the '${concept}' concept.";
    })
    primeMappingConfig.concepts;

  selfHostedHydraTasks = lib.map
    (concept: {
      name = "self-hosted-hydra-${concept}";
      file_path = "generated/self-hosted-hydra/${concept}.nix"; # Hydra jobset
      derivation_type = "schedule-self-hosted-hydra";
      llm_provider = "gemini"; # Added
      gemini_prompt = "Generate self-hosted Nix build Hydra jobset for the '${concept}' concept.";
    })
    primeMappingConfig.concepts;

  # New function to generate tasks for a specific LLM provider
  generateLLMTask = llmProvider: concept:
    let
      prompt = "Generate code for the '${concept}' concept using the ${llmProvider} LLM.";
    in
    {
      name = "${llmProvider}-gen-${concept}";
      file_path = "generated/${llmProvider}/${concept}.txt"; # Generic output file
      derivation_type = "generate-llm-code"; # New derivation type
      inherit llmProvider;
      gemini_prompt = prompt;
      estimatedUsage = {
        estimatedTokens = lib.strings.stringLength prompt * 2; # Simple estimation
        estimatedRequests = 1;
      };
    };

  # Tasks for each LLM provider
  geminiTasks = lib.map (concept: generateLLMTask "gemini" concept) primeMappingConfig.concepts;
  groqTasks = lib.map (concept: generateLLMTask "groq" concept) primeMappingConfig.concepts;
  amazonqTasks = lib.map (concept: generateLLMTask "amazonq" concept) primeMappingConfig.concepts;
  githubCopilotTasks = lib.map (concept: generateLLMTask "github-copilot" concept) primeMappingConfig.concepts;
  openaiCodexTasks = lib.map (concept: generateLLMTask "openai-codex" concept) primeMappingConfig.concepts;

  refineOeisSolverTask = {
    name = "refine-oeis-solver";
    file_path = "solvers/oeis-generator.mzn";
    derivation_type = "refine-minizinc"; # New derivation type
    llm_provider = "gemini"; # Added
    gemini_prompt = nix2llm.nix2llm (builtins.readFile ../solvers/oeis-generator.mzn) {
      purpose = "Refine the MiniZinc OEIS solver to implement recurrence relations, convergence criteria, and community contributions.";
      context = "The MiniZinc model is currently a simplified placeholder. The task description is embedded in the file's header.";
      expectedOutput = "A fully functional MiniZinc model that dynamically generates an OEIS sequence, proves its convergence, and integrates community input.";
    };
  };

  bootstrapPlanTask = {
    name = "bootstrap-plan-generation";
    file_path = "generated/bootstrap/plan.nix";
    derivation_type = "generate-bootstrap-plan"; # New derivation type
    llm_provider = "gemini";
    gemini_prompt = "Generate a Nix expression for a bootstrap plan to set up a single node with Gemini CLI and deploy the current system state. The plan should prioritize security and reproducibility.";
    estimatedUsage = {
      estimatedTokens = 500; # Dummy estimation
      estimatedRequests = 1;
    };
  };

in
moduleTasks ++ testTasks ++ lean4Tasks ++ rustTasks ++ tiktokTasks ++ dockerHubTasks ++ githubReleaseTasks ++ githubActionsTasks ++ awsCodeBuildTasks ++ selfHostedHydraTasks ++ [ refineOeisSolverTask ] ++ geminiTasks ++ groqTasks ++ amazonqTasks ++ githubCopilotTasks ++ openaiCodexTasks ++ [ bootstrapPlanTask ]
