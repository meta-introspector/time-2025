{ pkgs, lib, sopsSecretsPath, hostGeminiHome, ... }:

let
  # Import the generic makeContext
  makeContext = import ../monad-context.nix { inherit pkgs lib; };

  # Import the specific Gemini LLM module
  geminiLLM = import ../llm/gemini.nix { inherit pkgs lib sopsSecretsPath hostGeminiHome; };

  # Define the llmProviders attribute set for Gemini
  llmProviders = {
    gemini = geminiLLM;
  };

in
# Instantiate the generic makeContext with the Gemini LLM provider
makeContext { inherit llmProviders; }
