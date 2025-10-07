{ pkgs, lib, sopsSecretsPath, hostGeminiHome, ... }:

let
  # Import the generic makeContext
  makeContext = import ../monad-context.nix { inherit pkgs lib; };

  # Import the specific AmazonQ LLM module
  amazonqLLM = import ../llm/amazonq.nix { inherit pkgs lib sopsSecretsPath hostGeminiHome; };

  # Define the llmProviders attribute set for AmazonQ
  llmProviders = {
    amazonq = amazonqLLM;
  };

in
# Instantiate the generic makeContext with the AmazonQ LLM provider
makeContext { inherit llmProviders; }
