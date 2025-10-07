{ pkgs, lib, sopsSecretsPath, hostGeminiHome, ... }:

let
  # Import necessary modules
  # Use the Gemini-specific monad context provider
  geminiMonadContext = import ./lib/monad-context-providers/gemini.nix { inherit pkgs lib sopsSecretsPath hostGeminiHome; };
  nix2llm = import ./lib/nix2llm.nix { inherit lib; };
  geminiLLM = geminiMonadContext.llmProviders.gemini; # Access the Gemini LLM module from the specialized context

  # Convert orchestrator.nix to an LLM-friendly format
  orchestratorPrompt = import ./static-orchestrator-prompt.nix { inherit pkgs lib; };

  # Call the Gemini LLM with the constructed prompt
  llmOutput = geminiLLM.callApi orchestratorPrompt;

in
pkgs.stdenv.mkDerivation {
  name = "simulated-orchestrator-output";
  __impure = true; # Mark as impure because it depends on an impure LLM call
  buildCommand = ''
    mkdir -p $out
    cat ${llmOutput}/derivation-code.nix > $out/bootstrap-state.nix
  '';
}
