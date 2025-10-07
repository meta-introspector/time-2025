{ lib, pkgs, ... } @ args:

let
  primeMappingConfig = import ./prime-mapping-config.nix { inherit lib; };
  functorMatrix = import ./code-generation/functor-matrix.nix { inherit lib; };
  tiktokConfig = import ./tiktok-config.nix { inherit lib; };
  nix2llm = import ./nix2llm.nix { inherit lib; };
  oeisSolverResult = import ../solvers/run-oeis-solver.nix { inherit lib pkgs; config = {}; }; # Passed empty config
  currentOeisNumber = builtins.readFile oeisSolverResult.solverResult;

  # TODO: Make the Gemini prompts more sophisticated.
  generateTask = file_path: type: {
    name = "${type}-${(lib.strings.removeSuffix ".nix" (lib.strings.removePrefix "lib/emoji-encoding/" file_path))}";
    inherit file_path;
    derivation_type = type;
    gemini_prompt = "Create a Nix derivation to ${type} the file ${file_path}.";
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

  moduleTasks = lib.map (path: generateTask path "build") emojiEncodingModules;
  testTasks = lib.map (path: generateTask path "test") emojiEncodingTests;

  lean4Tasks = lib.map (concept: {
    name = "lean4-gen-${concept}";
    file_path = "generated/lean4/${concept}.lean";
    derivation_type = "generate-lean4";
    gemini_prompt = "Generate Lean4 code for the '${concept}' concept using the functorMatrix.lean4Generators.${concept} function.";
  }) primeMappingConfig.concepts;

  rustTasks = lib.map (concept: {
    name = "rust-gen-${concept}";
    file_path = "generated/rust/${concept}.rs";
    derivation_type = "generate-rust";
    gemini_prompt = "Generate Rust code for the '${concept}' concept using the functorMatrix.rustGenerators.${concept} function.";
  }) primeMappingConfig.concepts;

  tiktokTasks = lib.map (concept: {
    name = "tiktok-gen-${concept}";
    file_path = "${tiktokConfig.tiktokOutputPath}/${concept}${tiktokConfig.tiktokScriptExtension}"; # Markdown for TikTok script
    derivation_type = "generate-tiktok";
    gemini_prompt = tiktokConfig.generateTiktokPrompt concept currentOeisNumber;
  }) primeMappingConfig.concepts;

  dockerHubTasks = lib.map (concept: {
    name = "dockerhub-publish-${concept}";
    file_path = "generated/dockerhub/${concept}.json"; # Docker image config
    derivation_type = "publish-dockerhub";
    gemini_prompt = "Generate DockerHub publishing configuration for the '${concept}' concept.";
  }) primeMappingConfig.concepts;

  githubReleaseTasks = lib.map (concept: {
    name = "github-release-${concept}";
    file_path = "generated/github-release/${concept}.json"; # GitHub Release config
    derivation_type = "create-github-release";
    gemini_prompt = "Generate GitHub Release configuration for the '${concept}' concept.";
  }) primeMappingConfig.concepts;

  githubActionsTasks = lib.map (concept: {
    name = "github-actions-${concept}";
    file_path = "generated/github-actions/${concept}.yaml"; # GitHub Actions workflow
    derivation_type = "trigger-github-actions";
    gemini_prompt = "Generate GitHub Actions workflow for the '${concept}' concept.";
  }) primeMappingConfig.concepts;

  awsCodeBuildTasks = lib.map (concept: {
    name = "aws-codebuild-${concept}";
    file_path = "generated/aws-codebuild/${concept}.json"; # AWS CodeBuild config
    derivation_type = "build-aws-codebuild";
    gemini_prompt = "Generate AWS CodeBuild configuration for the '${concept}' concept.";
  }) primeMappingConfig.concepts;

  selfHostedHydraTasks = lib.map (concept: {
    name = "self-hosted-hydra-${concept}";
    file_path = "generated/self-hosted-hydra/${concept}.nix"; # Hydra jobset
    derivation_type = "schedule-self-hosted-hydra";
    gemini_prompt = "Generate self-hosted Nix build Hydra jobset for the '${concept}' concept.";
  }) primeMappingConfig.concepts;

  refineOeisSolverTask = {
    name = "refine-oeis-solver";
    file_path = "solvers/oeis-generator.mzn";
    derivation_type = "refine-minizinc"; # New derivation type
    gemini_prompt = nix2llm.nix2llm (builtins.readFile ../solvers/oeis-generator.mzn) {
      purpose = "Refine the MiniZinc OEIS solver to implement recurrence relations, convergence criteria, and community contributions.";
      context = "The MiniZinc model is currently a simplified placeholder. The task description is embedded in the file's header.";
      expectedOutput = "A fully functional MiniZinc model that dynamically generates an OEIS sequence, proves its convergence, and integrates community input.";
    };
  };

in
moduleTasks ++ testTasks ++ lean4Tasks ++ rustTasks ++ tiktokTasks ++ dockerHubTasks ++ githubReleaseTasks ++ githubActionsTasks ++ awsCodeBuildTasks ++ selfHostedHydraTasks ++ [refineOeisSolverTask]
