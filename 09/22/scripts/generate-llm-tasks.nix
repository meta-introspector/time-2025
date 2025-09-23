{
  # Inputs for this generator flake
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    llmTaskTemplate = {
      url = "path:../flake-templates/llm-task-template"; # Relative path to the template flake
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
  };

  outputs = { self, nixpkgs, flake-utils, llmTaskTemplate }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        # Define your tasks here
        tasks = [
          {
            name = "oeis-interpretation";
            narFileName = "llm-context-OEIS-latest.nar";
            promptTemplate = "Using the following context from OEIS, provide a creative and esoteric interpretation of the sequence:\n\n{LLM_CONTEXT}\n\nInterpretation:";
            llmModel = "gemini-2.5-flash";
          }
          {
            name = "monster-group-analysis";
            narFileName = "mh3fw1685yrjzdqzhvn1nxvw5h09mpvh-llm-context-Monster-Group.nar"; # Example from crq-binstore
            promptTemplate = "Analyze the provided Monster Group context and describe its significance in mathematics:\n\n{LLM_CONTEXT}\n\nSignificance:";
            llmModel = "gemini-1.5-pro";
          }
          # Add more tasks as needed
        ];

        # Function to generate a flake for a single task
        generateTaskFlake = task:
          let
            taskDir = ../generated-tasks + "/${task.name}";
            flakeContent = ''
              {
                inputs = {
                  llmTaskTemplate = {
                    url = "path:../../flake-templates/llm-task-template";
                    inputs.nixpkgs.follows = "nixpkgs";
                    inputs.flake-utils.follows = "flake-utils";
                  };
                  nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
                  flake-utils.url = "github:numtide/flake-utils";
                };

                outputs = { self, nixpkgs, flake-utils, llmTaskTemplate }:
                  flake-utils.lib.eachDefaultSystem (system:
                    let
                      pkgs = nixpkgs.legacyPackages.${system};
                    in
                    {
                      packages.default = llmTaskTemplate.lib.mkLlmTask {
                        narFileName = "${task.narFileName}";
                        promptTemplate = builtins.toJSON ''${task.promptTemplate}'';
                        llmModel = "${task.llmModel}";
                      };
                      devShells.default = pkgs.mkShell {
                        buildInputs = [ pkgs.nix ];
                        shellHook = ''
                          echo "Entering devShell for ${task.name}.";
                          echo "To run the task: nix build .#default && $(${pkgs.nix.outPath}/bin/nix-store --query --read-symlinks $(nix build .#default --no-link --print-out-paths))/bin/run-llm-task.sh"
                        '';
                      };
                    }
                  );
              }
            '';
          in
          pkgs.runCommand "generate-task-flake-${task.name}" {}
            ''
              mkdir -p ${taskDir}
              echo "${flakeContent}" > ${taskDir}/flake.nix
            ''
      in
      {
        # Expose the generated flakes as packages
        packages = builtins.listToAttrs (map (task: { 
          name = task.name;
          value = generateTaskFlake task;
        }) tasks);
      }
    );
}
