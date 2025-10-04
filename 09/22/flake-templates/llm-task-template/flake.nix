{
  description = "Template Nix flake for LLM tasks with dynamic NAR and prompt.";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
    flake-utils.url = "github:meta-introspector/flake-utils?ref=feature/CRQ-016-nixify";
    crq-binstore.url = "github:meta-introspector/time-2025/feature/foaf?dir=09/22/crq-binstore";
    # Assuming the gemini-cli is available from this flake
    geminiCliFlake = {
      url = "github:meta-introspector/gemini-cli?ref=feature/working-gemini-cli-nix-store";
      inputs.nixpkgs.follows = "nixpkgs"; # Ensure consistency
    };
  };

  outputs = { self, nixpkgs, flake-utils, crq-binstore, geminiCliFlake }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        # Define default values for arguments
        defaultNarFileName = "llm-context-OEIS-latest.nar";
        defaultPromptTemplate = "Using the following context, provide a creative and esoteric interpretation of numbers:\n\n{LLM_CONTEXT}\n\nInterpretation:";
        defaultLlmModel = "gemini-2.5-flash"; # Example, can be passed as argument

        # Function to create a task derivation
        mkLlmTask = { narFileName ? defaultNarFileName, promptTemplate ? defaultPromptTemplate, llmModel ? defaultLlmModel }:
          pkgs.stdenv.mkDerivation {
            pname = "llm-task-${narFileName}";
            version = "0.1.0";

            # Pass arguments as environment variables to the build script
            buildInputs = [ pkgs.nix pkgs.bash pkgs.jq ]; # Added pkgs.jq
            GEMINI_CLI = "${geminiCliFlake.packages.${system}.gemini-cli}/bin/gemini-cli"; # Path to the actual gemini-cli executable
            CRQ_BINSTORE_PATH = crq-binstore;
            NAR_FILE_NAME = narFileName;
            PROMPT_TEMPLATE = promptTemplate;
            LLM_MODEL = llmModel;

            # The actual script that runs the task
            # This script will be generated or copied into the derivation
            # For now, let's embed it directly for simplicity
            # In a more complex scenario, we might have a separate script file
            # that gets parameterized and copied.
            installPhase = ''
                            mkdir -p $out/bin

                            # Create the fetch-nar-data.sh script within the derivation
                            cat > $out/bin/fetch-nar-data.sh << EOF
              #!/usr/bin/env bash
              set -euo pipefail
              NAR_FILE="$NAR_FILE_NAME"
              CRQ_BINSTORE_PATH="$CRQ_BINSTORE_PATH"
              OUTPUT_DIR="$out/unpacked-nar-data" # Unpack directly into the output

              if [[ -z "$NAR_FILE" ]]; then
                echo "Error: NAR_FILE_NAME is not set."
                exit 1
              fi
              if [[ -z "$CRQ_BINSTORE_PATH" ]]; then
                echo "Error: CRQ_BINSTORE_PATH is not set."
                exit 1
              fi

              NAR_PATH="''${CRQ_BINSTORE_PATH}/''${NAR_FILE}"

              if [[ ! -f "$NAR_PATH" ]]; then
                echo "Error: NAR file not found at ''${NAR_PATH}"
                exit 1
              fi

              echo "Unpacking NAR file: ''${NAR_PATH}"
              mkdir -p "''${OUTPUT_DIR}"
              nix-nar-unpack --file "''${NAR_PATH}" --to "''${OUTPUT_DIR}"

              echo "NAR file unpacked to: ''${OUTPUT_DIR}"
              EOF
                            chmod +x $out/bin/fetch-nar-data.sh

                            # Create the run-llm-task.sh script within the derivation
                            cat > $out/bin/run-llm-task.sh << EOF
              #!/usr/bin/env bash
              set -euo pipefail

              echo "Starting LLM task with NAR data..."

              # Step 1 & 2: Fetching and unpacking NAR file
              echo "Fetching and unpacking NAR file: $NAR_FILE_NAME"
              $out/bin/fetch-nar-data.sh

              UNPACKED_DATA_DIR="$out/unpacked-nar-data"

              if [[ ! -d "$UNPACKED_DATA_DIR" ]]; then
                echo "Error: Unpacked data directory not found: ''${UNPACKED_DATA_DIR}"
                exit 1
              fi

              # Step 3: Load the data
              DATA_FILE="''${UNPACKED_DATA_DIR}/llm-context-OEIS-latest.txt" # Adjust based on actual NAR content

              if [[ ! -f "$DATA_FILE" ]]; then
                echo "Error: Data file not found in unpacked NAR: ''${DATA_FILE}"
                exit 1
              fi

              LLM_CONTEXT=$(cat "''${DATA_FILE}")

              echo "Loaded LLM context from NAR file. First 100 characters:"
              echo "''${LLM_CONTEXT:0:100}..."

              # Step 4: Construct a prompt for Gemini
              # Replace {LLM_CONTEXT} in the template
              GENERATED_PROMPT=$(echo "$PROMPT_TEMPLATE" | ${pkgs.jq}/bin/jq -r . | sed "s/{LLM_CONTEXT}/''${LLM_CONTEXT}/g")

              echo "Generated Gemini Prompt (first 200 chars):"
              echo "''${GENERATED_PROMPT:0:200}..."

              # Step 5: Execute the Gemini LLM task
              echo "Executing Gemini LLM task with model: $LLM_MODEL"
              $GEMINI_CLI --model=$LLM_MODEL --prompt "''${GENERATED_PROMPT}"

              echo "LLM task completed."
              EOF
                            chmod +x $out/bin/run-llm-task.sh
            '';
          };
      in
      {
        # Expose the mkLlmTask function for external use
        lib.mkLlmTask = mkLlmTask;

        # Example of a default task using the template
        packages.default = mkLlmTask { };
      });
}
