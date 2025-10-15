{ pkgs, lib, builtins, llmGeneratorFlake }:
flakePath: # This task is now a function that takes flakePath
let
  # Helper to check if a flake output exists and builds
  checkFlakeOutput = outputName: flakePath: # flakePath is now an argument
    pkgs.runCommand "check-${(lib.strings.sanitizeDerivationName outputName)}-output"
      {
        inherit flakePath;
        output = outputName;
        # We need to ensure the flake path is a valid Nix store path or a path that Nix can resolve.
        # For simplicity, we assume flakePath is directly usable by nix build.
        # In a real scenario, you might need to ensure it's a store path or a flake reference.
      }
      '
      bash ${./check-flake-output.sh}';

  # This is the main function that takes flakePath as an argument
  documentSingleFlakePipeline = flakePath:
    let
      # Step 1: Check for and build existing docs.md target
      checkDocStatus = checkFlakeOutput "docs.md" flakePath;

      # Step 2: Pure documentation generation
      pureDocGeneration = pkgs.stdenv.mkDerivation {
        name = "pure-doc-generation";
        inherit flakePath;

        # This derivation will depend on the checkDocStatus to decide if it needs to run
        # For now, we'll always try to generate if docs are not found.

        # We need to import the llm-pipeline.nix from llmGeneratorFlake
        llmPipeline = llmGeneratorFlake.lib.${pkgs.system}.llmPipeline;

        # Construct the LLM call vector for documentation
        llmCallVectorDescription = (llmPipeline.llmCallVectorFunctor) {
          inherit lib;
          calls = [
            (llmPipeline.llmFunctor)
            {
              checksum = lib.hashFile "sha256" flakePath; # Use flakePath hash as checksum
              keyObject = llmPipeline.myKeyObject; # Dummy key object
              modelRouter = llmPipeline.myModelRouter; # Dummy model router
              prompt = "Generate comprehensive documentation for the following Nix flake.nix file, including its purpose, inputs, and outputs, in Markdown format:\n\n```nix\n${builtins.readFile flakePath}\n```";
              expectedOutputFormat = "markdown";
            }
          ];
        };

        # This derivation will run the llm-orchestrator.sh in a pure context
        # to get the LLM tasks. The actual LLM call is still deferred.
        builder = pkgs.writeScript "pure-doc-generator-builder" (pkgs.writeScript "pure-doc-generator-builder-wrapper" 'bash ${ ./pure-doc-generator-builder.sh}');

        # Dependencies for the builder script
        buildInputs = [ pkgs.bash pkgs.jq ];

        # Pass the necessary Nix objects to the builder script
        # This is done via the builder script itself, as it's a pkgs.writeScript
      };

      # Step 3: Apply pure generated documentation to the flake
      applyPureDoc = pkgs.runCommand "apply-pure-doc"
        {
          inherit flakePath;
          generatedDocContent = pureDocGeneration; # Input from previous step
          # We need the original flake content to modify it
          originalFlakeContent = builtins.readFile flakePath;
          buildInputs = [ pkgs.gnused pkgs.nix ]; # Add sed and nix for parsing
        }
        let
        docContent = builtins.readFile generatedDocContent;
      originalContent = builtins.readFile flakePath;
      insertionPoint = "};";
      newDocBlock = "      docs.md = pkgs.writeText \"$(basename \"$flakePath\" .nix)-docs.md\" ''''\n${docContent}\n      '''';\n";

      # Split the original content by the insertion point and insert the new doc block
      parts = lib.strings.splitString insertionPoint originalContent;
      modifiedContent = lib.strings.concatStringsSep (newDocBlock + insertionPoint) (lib.lists.take (builtins.length parts - 1) parts) + insertionPoint + lib.lists.last parts;
    in
    pkgs.writeText "flake.nix" modifiedContent;
  # Step 4: Impure documentation generation (fallback if pure fails)
  impureDocGeneration = pkgs.runCommand "impure-doc-generation" {
    inherit flakePath;

    # Mark as impure to allow external network access and homedir access
    __noChroot = true;
    __noSandbox = true;

    # We need to import the llm-pipeline.nix from llmGeneratorFlake
    llmPipeline = llmGeneratorFlake.lib.${pkgs.system}.llmPipeline;

    # Construct the LLM call vector for documentation
    llmCallVectorDescription = (llmPipeline.llmCallVectorFunctor) {
      inherit lib;
      calls = [
        (llmPipeline.llmFunctor)
        {
          checksum = lib.hashFile "sha256" flakePath; # Use flakePath hash as checksum
          keyObject = llmPipeline.myKeyObject; # Dummy key object
          modelRouter = llmPipeline.myModelRouter; # Dummy model router
          prompt = "Generate comprehensive documentation for the following Nix flake.nix file, including its purpose, inputs, and outputs, in Markdown format. This is an impure fallback call, so be extra thorough:\n\n```nix\n${builtins.readFile flakePath}\n```";
          expectedOutputFormat = "markdown";
        }
      ];
    };

    # This derivation will run the llm-orchestrator.sh in an impure context
    builder = pkgs.writeScript "impure-doc-generator-builder" (pkgs.writeScript "impure-doc-generator-builder-wrapper" ''
      bash ${./impure-doc-generator-builder.sh}
    '');

    # Dependencies for the builder script
    buildInputs = [ pkgs.bash pkgs.jq ];

  };

  # Step 5: Apply impure generated documentation to the flake
  applyImpureDoc = pkgs.runCommand "apply-impure-doc"
    {
      inherit flakePath;
      generatedDocContent = impureDocGeneration; # Input from previous step
      originalFlakeContent = builtins.readFile flakePath;
      buildInputs = [ pkgs.gnused pkgs.nix ]; # Add sed and nix for parsing
    }
    let
    docContent = builtins.readFile generatedDocContent;
  originalContent = builtins.readFile flakePath;
  insertionPoint = "};";
  newDocBlock = "      docs.md = pkgs.writeText \"$(basename \"$flakePath\" .nix)-docs.md\" ''''\n${docContent}\n      '''';\n";

  # Split the original content by the insertion point and insert the new doc block
  parts = lib.strings.splitString insertionPoint originalContent;
  modifiedContent = lib.strings.concatStringsSep (newDocBlock + insertionPoint) (lib.lists.take (builtins.length parts - 1) parts) + insertionPoint + lib.lists.last parts;
in
pkgs.writeText "flake.nix" modifiedContent;

# Step 6: Final Result Selection and Reporting
finalResult = pkgs.runCommand "final-doc-result" {
inherit flakePath;
checkDocStatusResult = checkDocStatus;
applyPureDocResult = applyPureDoc;
applyImpureDocResult = applyImpureDoc;

# We need to read the status files from the checkDocStatusResult
checkDocStatus = builtins.fromJSON (builtins.readFile "${checkDocStatus}/status");

# This script will decide which flake to output and what status to report
}
bash ${./final-doc-result.sh} ;
in
{
name = "document-single-flake-pipeline";
description = "A pipeline to check, generate, and apply documentation for a single flake.nix file.";

# Expose the intermediate steps as derivations
inherit checkDocStatus pureDocGeneration applyPureDoc impureDocGeneration applyImpureDoc finalResult;

# Also expose a default output for convenience
default = finalResult;
};
in
{
# Expose the main function as a lib output
lib.documentSingleFlakePipeline = documentSingleFlakePipeline;

# Also expose a default package that calls the pipeline with a dummy flakePath
packages.${pkgs.system} .default = documentSingleFlakePipeline (pkgs.writeText "dummy-flake.nix" "{}");
}
