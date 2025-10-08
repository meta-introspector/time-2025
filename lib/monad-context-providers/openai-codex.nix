{ pkgs, lib, sopsSecretsPath, hostGeminiHome, ... }:

let
  # Import the generic makeContext
  makeContext = import ../monad-context.nix { inherit pkgs lib; };

  # Import the specific OpenAI Codex LLM module
  openaiCodexLLM = import ../llm/openai-codex.nix { inherit pkgs lib sopsSecretsPath hostGeminiHome; };

  # Define the llmProviders attribute set for OpenAI Codex
  llmProviders = {
    openai-codex = openaiCodexLLM;
  };

in
# Instantiate the generic makeContext with the OpenAI Codex LLM provider
makeContext { inherit llmProviders; }
