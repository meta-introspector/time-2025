{
  description = "An LLM-powered simulator for Nix expressions, translating abstract Nix concepts to concrete execution insights.";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
    llmApiWrapper = {
      # This input will be provided by the caller (e.g., test-llm-nix-simulator.nix)
      # It should be a flake that provides the LLM API wrapper
      flake = true;
    };
    # Input for the Nix expression to simulate
    nixExpressionToSimulate = {
      flake = false; # We want the raw Nix expression file
    };
  };

  outputs = { self, nixpkgs, llmApiWrapper, nixExpressionToSimulate }:
    let
      # Import lib files
      pkgs = import ./lib/pkgs.nix { inherit nixpkgs; system = "aarch64-linux"; };
      analyzedNixExpression = import ./lib/analyzed-nix-expression.nix { inherit pkgs nixExpressionToSimulate; };
      promptFileDerivation = import ./lib/prompt-file-derivation.nix { inherit pkgs analyzedNixExpression; };
      simulatedNixRun = import ./lib/simulated-nix-run.nix { inherit pkgs analyzedNixExpression promptFileDerivation llmApiWrapper; };
    in
    {
      packages.aarch64-linux = import ./lib/packages.nix { inherit simulatedNixRun; };
    };
}
