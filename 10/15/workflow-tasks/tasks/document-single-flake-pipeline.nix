{ pkgs, lib, builtins, llmGeneratorFlake }:
flakePath: # This task is now a function that takes flakePath
let
  # Helper to check if a flake output exists and builds
  checkFlakeOutput = outputName:
    pkgs.runCommand "check-${(lib.strings.sanitizeDerivationName outputName)}-output"
      {
        inherit flakePath;
        output = outputName;
        # We need to ensure the flake path is a valid Nix store path or a path that Nix can resolve.
        # For simplicity, we assume flakePath is directly usable by nix build.
        # In a real scenario, you might need to ensure it's a store path or a flake reference.
      } ''
      set +e # Don't exit on first error
      if nix build "$flakePath".#"$output" --no-link &> "$out/build_log.txt"; then
        echo "status=success" > "$out/status"
        cp "$(nix build "$flakePath".#"$output" --no-link --print-out-paths)" "$out/content"
      else
        echo "status=failure" > "$out/status"
        cat "$out/build_log.txt" > "$out/error_log.txt"
      fi
    '';

  # Step 1: Check for and build existing docs.md target
  checkDocStatus = checkFlakeOutput "docs.md";

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
    builder = pkgs.writeScript "pure-doc-generator-builder" ''
      set -euo pipefail
      
      # The llm-orchestrator.sh expects these as arguments
      LLM_CALL_VECTOR_JSON="$(builtins.toJSON llmCallVectorDescription)"
      KEY_OBJECT_JSON="$(builtins.toJSON llmPipeline.myKeyObject)"
      MODEL_ROUTER_JSON="$(builtins.toJSON llmPipeline.myModelRouter)"
      FLAKE_CONTENT="$(builtins.readFile flakePath)"

      # Invoke the llm-orchestrator.sh script
      # This will output a JSON array of LLM tasks
      LLM_TASKS_JSON="$(bash ${llmPipeline.llmOrchestratorScript} "$LLM_CALL_VECTOR_JSON" "$KEY_OBJECT_JSON" "$MODEL_ROUTER_JSON" "$FLAKE_CONTENT")"

      # For now, we'll just output the first task's description as the generated doc content
      # In a real scenario, we'd process all tasks and extract the actual LLM response
      echo "$LLM_TASKS_JSON" | jq -r '.[0].taskDescription' > "$out"
    '';

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
    } ''
    set -euo pipefail

    # Read the generated documentation content
    DOC_CONTENT=$(cat "$generatedDocContent")

    # Read the original flake.nix content
    ORIGINAL_FLAKE_CONTENT="$originalFlakeContent"

    # Find the insertion point: before the last '};' in the outputs section
    # This is a simplified approach and might break with complex flake structures.
    # A more robust solution would involve Nix AST manipulation.
    INSERTION_POINT="};"
    NEW_DOC_BLOCK="      docs.md = pkgs.writeText \"$(basename "$flakePath" .nix)-docs.md\" ''\n$DOC_CONTENT\n      '';
  "

    # Use sed to insert the new doc block before the last '};'
    # This assumes the last '};' is the correct place to insert.
    # This is highly brittle and for demonstration purposes.
    echo "$ORIGINAL_FLAKE_CONTENT" |\
    sed -e "s|${INSERTION_POINT}|${NEW_DOC_BLOCK}\\n${INSERTION_POINT}|g" > "$out/flake.nix";\
    nix-instantiate --parse "$out/flake.nix";
  '';

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
        (llmPipeline.llmFunctor) {
          checksum = lib.hashFile "sha256" flakePath; # Use flakePath hash as checksum
          keyObject = llmPipeline.myKeyObject; # Dummy key object
          modelRouter = llmPipeline.myModelRouter; # Dummy model router
          prompt = "Generate comprehensive documentation for the following Nix flake.nix file, including its purpose, inputs, and outputs, in Markdown format. This is an impure fallback call, so be extra thorough:\n\n```nix\n${builtins.readFile flakePath}\n```";
          expectedOutputFormat = "markdown";
        }
      ];
    };

    # This derivation will run the llm-orchestrator.sh in an impure context
    builder = pkgs.writeScript "impure-doc-generator-builder" ''
      set -euo pipefail
      
      # The llm-orchestrator.sh expects these as arguments
      LLM_CALL_VECTOR_JSON="$(builtins.toJSON llmCallVectorDescription)"
      KEY_OBJECT_JSON="$(builtins.toJSON llmPipeline.myKeyObject)"
      MODEL_ROUTER_JSON="$(builtins.toJSON llmPipeline.myModelRouter)"
      FLAKE_CONTENT="$(builtins.readFile flakePath)"

      # Invoke the llm-orchestrator.sh script
      # This will output a JSON array of LLM tasks
      LLM_TASKS_JSON="$(bash ${llmPipeline.llmOrchestratorScript} "$LLM_CALL_VECTOR_JSON" "$KEY_OBJECT_JSON" "$MODEL_ROUTER_JSON" "$FLAKE_CONTENT")"

      # For now, we'll just output the first task's description as the generated doc content
      # In a real scenario, we'd process all tasks and extract the actual LLM response
      echo "$LLM_TASKS_JSON" | jq -r '.[0].taskDescription' > "$out"
    '';
    
    # Dependencies for the builder script
    buildInputs = [ pkgs.bash pkgs.jq ];
    
  };

  # Step 5: Apply impure generated documentation to the flake
  applyImpureDoc = pkgs.runCommand "apply-impure-doc" {
    inherit flakePath;
    generatedDocContent = impureDocGeneration; # Input from previous step
    originalFlakeContent = builtins.readFile flakePath;
    buildInputs = [ pkgs.gnused pkgs.nix ]; # Add sed and nix for parsing
  } ''
    set -euo pipefail

    DOC_CONTENT=$(cat "$generatedDocContent")
    ORIGINAL_FLAKE_CONTENT="$originalFlakeContent"
    INSERTION_POINT="};"
    NEW_DOC_BLOCK="      docs.md = pkgs.writeText \"$(basename "$flakePath " .nix)-docs.md\" ''\n$DOC_CONTENT\n      '';"

    echo "$ORIGINAL_FLAKE_CONTENT" |\
    sed - e "s|${INSERTION_POINT}|${NEW_DOC_BLOCK}\\n${INSERTION_POINT}|g" > "$out/flake.nix"; \
  nix-instantiate --parse "$out/flake.nix";
  '';

  # Step 6: Final Result Selection and Reporting
  finalResult = pkgs.runCommand "final-doc-result" {
    inherit flakePath;
    checkDocStatusResult = checkDocStatus;
    applyPureDocResult = applyPureDoc;
    applyImpureDocResult = applyImpureDoc;

    # We need to read the status files from the checkDocStatusResult
    checkDocStatus = builtins.fromJSON (builtins.readFile "${checkDocStatus}/status");

    # This script will decide which flake to output and what status to report
  } ''
  set - euo pipefail

  FINAL_FLAKE_PATH = ""
    FINAL_STATUS=""
  REPORT_MESSAGE=""

  # Check if docs already existed and built successfully
  if [ "$(cat "$checkDocStatusResult/status")" = "status=success" ];
  then
  FINAL_FLAKE_PATH = "$flakePath"
    FINAL_STATUS="docs_already_exist"
  REPORT_MESSAGE="Documentation already existed and built successfully."
  elif [ -e "$applyPureDocResult" ];
  then # Check if pure application succeeded
  FINAL_FLAKE_PATH = "$applyPureDocResult"
    FINAL_STATUS="pure_generation_success"
  REPORT_MESSAGE="Documentation generated and applied purely."
  elif [ -e "$applyImpureDocResult" ];
  then # Check if impure application succeeded
  FINAL_FLAKE_PATH = "$applyImpureDocResult"
    FINAL_STATUS="impure_generation_success"
  REPORT_MESSAGE="Documentation generated and applied impurely (fallback)."
  else
  FINAL_FLAKE_PATH="$flakePath" # Output original flake if all else fails
  FINAL_STATUS="generation_failed"
  REPORT_MESSAGE="Documentation generation failed for both pure and impure paths."
  fi

  # Create a report file
  cat > "$out/report.json" <<EOF
  {
  "flakePath": "$flakePath",
  "finalFlakePath": "$FINAL_FLAKE_PATH",
  "status": "$FINAL_STATUS",
  "message": "$REPORT_MESSAGE"
  }
  EOF

  # Create a symlink to the final flake for convenience
  ln -s "$FINAL_FLAKE_PATH" "$out/documented-flake.nix"
  ''               ;



in
{
  name = "document-single-flake-pipeline";
  description = "A pipeline to check, generate, and apply documentation for a single flake.nix file.";

  # Expose the intermediate steps as derivations
  inherit checkDocStatus pureDocGeneration applyPureDoc impureDocGeneration applyImpureDoc finalResult;

  # Also expose a default output for convenience
  default = finalResult;
}










