let
  # Define pkgs for the test environment
  pkgs = import <nixpkgs> { system = "aarch64-linux"; };

  # 1. Build the hackathon-consumer-flake to get the JSON results
  hackathonConsumerFlake = (builtins.getFlake (toString ../hackathon/consumer)).outputs;
  hackathonResults = hackathonConsumerFlake.packages.aarch64-linux.default;

  # 2. Build the llm-data-extractor-flake
  llmDataExtractorFlake = (builtins.getFlake (toString ./llm-data-extractor-flake)).outputs;
  impureLlmResult = llmDataExtractorFlake.packages.aarch64-linux.default {
    inherit pkgs hackathonResults;
    # Placeholder for llmApiWrapper, as it's not yet implemented
    llmApiWrapper = pkgs.runCommand "dummy-llm-api-wrapper" {} ''
      mkdir -p $out/bin
      echo '#!${pkgs.bash}/bin/bash' > $out/bin/call-llm-api
      echo 'echo "{\"project_name\": \"Dummy Project\", \"team_members\": [\"Dummy Member\"], \"technologies_used\": [\"Nix\"], \"project_description\": \"A dummy project for testing.\", \"link_to_repo\": \"https://example.com/dummy\"}"' >> $out/bin/call-llm-api
      chmod +x $out/bin/call-llm-api
    ''; # Added semicolon here
  };

  # 3. Build the llm-result-purifier-flake
  llmResultPurifierFlake = (builtins.getFlake (toString ./llm-result-purifier-flake)).outputs;
  pureLlmResult = llmResultPurifierFlake.packages.aarch64-linux.default {
    inherit pkgs impureLlmResult;
    narBridgeFlake = (builtins.getFlake (toString ../hackathon/nar-bridge-flake)).outputs;
  };

in
  pureLlmResult
