{ pkgs, lib, sopsSecretsPath, hostGeminiHome, ... }:

let
  # Import the generic makeContext
  makeContext = import ../monad-context.nix { inherit pkgs lib; };

  # Import the specific GitHub Copilot LLM module
  githubCopilotLLM = import ../llm/github-copilot.nix { inherit pkgs lib sopsSecretsPath hostGeminiHome; };

  # Define the llmProviders attribute set for GitHub Copilot
  llmProviders = {
    github-copilot = githubCopilotLLM;
  };

in
# Instantiate the generic makeContext with the GitHub Copilot LLM provider
makeContext { inherit llmProviders; }
