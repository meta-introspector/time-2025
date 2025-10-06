{
  description = "Consolidated Nix flake for AI/LLM workflows, providing impure LLM job execution and AI derivation functions.";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
    flake-utils.url = "github:meta-introspector/flake-utils?ref=feature/CRQ-016-nixify";
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        # --- From impure-llm-job/flake.nix ---
        # Function to load secrets from a pre-decrypted file
        loadImpureSecrets = _:
          let
            decryptedPath = builtins.getEnv "LLM_API_KEY_FILE" ""; # Get path from host env
            hasDecrypted = builtins.pathExists decryptedPath;
          in
          if hasDecrypted then
            builtins.readFile decryptedPath # Read the content of the decrypted file
          else
            throw "LLM_API_KEY_FILE environment variable not set or file not found for impure build.";

        llmJob = pkgs.stdenv.mkDerivation {
          pname = "llm-impure-job";
          version = "1.0";
          src = pkgs.writeText "dummy-source" ""; # Provide a dummy source

          dontUnpack = true; # No need to unpack a plain text file

          __impure = true; # Allow network access and host filesystem access

          # Pass the API key as an environment variable to the buildPhase
          # This makes it available as $LLM_API_KEY in the build script
          buildInputs = [ pkgs.curl pkgs.python3 ]; # Example build inputs

          buildPhase = ''
            echo "Starting impure LLM build..."
            echo "LLM setup complete"
          '';

          installPhase = ''
            mkdir -p $out/bin
            echo "LLM job built successfully" > $out/status.txt
            cp models.json $out/models.json || true
          '';
        };

        # --- From response-010-ai-derivation-script/flake.nix ---
        # Placeholder for the AI inference tool
        aiInferenceTool = pkgs.writeShellScript "ai-inference-tool" ''
          echo "--- AI Inference Tool ---"
          echo "Received NAR paths for inference:"
          while IFS= read -r nar_path; do
            echo "  - $nar_path"
            # Simulate AI processing: extract content and summarize
            local temp_extract_dir=$(mktemp -d)
            nix-store --dump $nar_path | nix-nar-unpack $temp_extract_dir
            echo "  Extracted content from $nar_path to $temp_extract_dir"
            echo "  Content summary:"
            find $temp_extract_dir -type f -print0 | xargs -0 cat
            echo "--- End of content summary ---"
            rm -rf $temp_extract_dir
          done
          echo "--- AI Inference Complete ---"
          echo "AI Inference Result: This is a simulated AI output based on the input NARs."
        '';

        # Function to run a flake impurely and produce an AI derivation
        runFlakeForAI = { flakeRef }:
          let
            inputCli = pkgs.callPackage
              ({ rustPlatform, lib, openssl, nix }:
                rustPlatform.buildRustPackage {
                  pname = "input-cli"; # Dummy name, actual name comes from input flake
                  version = "0.1.0";
                  src = flakeRef; # Use the input flake as source
                  cargoLock = "${flakeRef}/Cargo.lock"; # Assuming Cargo.lock is at the workspace root
                  buildInputs = [ openssl nix ];
                  cargoRoot = flakeRef;
                  sourceRoot = "streamofrandom_cli"; # Assuming the actual package is in this subdir
                }
              )
              { };

            aiDerivation = pkgs.runCommand "ai-inference-result"
              {
                buildInputs = [ pkgs.bash pkgs.nix pkgs.coreutils pkgs.findutils pkgs.gnused pkgs.gnugrep pkgs.gawk pkgs.nix-nar-unpack aiInferenceTool ];
                GEMINI_CONFIG_DIR = "/homeless-shelter/.gemini"; # Point to a dummy location for build
                HOME = "/homeless-shelter"; # Set a dummy HOME for the build environment

                inputCliOutput = pkgs.runCommand "input-cli-simulated-output"
                  {
                    buildInputs = [ inputCli pkgs.nix ];
                    dummyNar = pkgs.writeText "dummy-nar-content" "dummy content";
                  } ''
                  echo "$(nix-store --dump $dummyNar)" > $out
                '';

              } ''
              local ai_output_dir=$(mktemp -d)
              local nar_paths=$(cat $inputCliOutput)
              echo "$nar_paths" | $aiInferenceTool > $ai_output_dir/ai_inference_log.txt
              cp -r $ai_output_dir/* $out
            '';
          in
          aiDerivation;

      in
      {
        # Expose the runFlakeForAI function
        lib.runFlakeForAI = runFlakeForAI;

        # Default package demonstrates the impure LLM job
        packages.default = llmJob;

        # Development shell for AI workflows
        devShells.default = pkgs.mkShell {
          nativeBuildInputs = [ pkgs.bash pkgs.nix pkgs.curl pkgs.python3 ];
          shellHook = ''
            echo "Welcome to the AI Workflow devShell!"
            echo "You can run the impure LLM job with: nix build .#default"
            echo "Or use the runFlakeForAI function from lib."
            echo "Example: nix build -f . --arg flakeRef ../response-007-cli-nar-output"
          '';
        };
      }
    );
}