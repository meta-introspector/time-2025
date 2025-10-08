{
  description = "Feature 11: LLM Output Capture - Captures all output files from LLM execution.";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
    flake-utils.url = "github:meta-introspector/flake-utils?ref=feature/CRQ-016-nixify";
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        inherit lib;

        # A function that takes an LLM execution derivation and ensures its outputs are captured
        captureLLMOutputs = { llmExecutionDerivation }:
          pkgs.stdenv.mkDerivation {
            pname = "llm-output-capture";
            version = "1.0";

            src = llmExecutionDerivation; # The LLM execution derivation is the source

            buildPhase = ''
              mkdir -p $out/llm-outputs
              cp -r $src/* $out/llm-outputs/
              echo "✅ All LLM outputs from $src captured to $out/llm-outputs/"
            '';

            installPhase = ''
              echo "LLM outputs available in $out/llm-outputs/"
            '';
          };

      in
      {
        lib = {
          inherit captureLLMOutputs;
        };

        packages.default = pkgs.writeText "llm-output-capture-feature" "This flake provides LLM output capture.";
      }
    );
}