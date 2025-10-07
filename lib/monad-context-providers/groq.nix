{ pkgs, lib, sopsSecretsPath, hostGeminiHome, ... }:

let
  # Import the generic makeContext
  makeContext = import ../monad-context.nix { inherit pkgs lib; };

  # Import the specific Groq LLM module
  groqLLM = import ../llm/groq.nix { inherit pkgs lib sopsSecretsPath hostGeminiHome; };

  # Define the llmProviders attribute set for Groq
  llmProviders = {
    groq = groqLLM;
  };

in
# Instantiate the generic makeContext with the Groq LLM provider
makeContext { inherit llmProviders; }
