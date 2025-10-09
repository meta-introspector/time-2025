{
  description = "A flake to purify and record the results of an impure LLM task flake.";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
    narBridgeFlake = {
      url = "path:../hackathon/nar-bridge-flake"; # Reference our nar-bridge-flake
      flake = true;
    };
    impureLlmResult = {
      # This input will be the output of the impure LLM task flake
      # It should be a derivation containing the extracted data
      flake = false; # We want the raw derivation output
    };
  };

  outputs = { self, nixpkgs, narBridgeFlake, impureLlmResult }:
    let
      pkgs = nixpkgs.legacyPackages.aarch64-linux;

      # Create a fixed-output derivation from the impure LLM result
      # This makes the result pure and content-addressed
      pureLlmResult = pkgs.runCommand "pure-llm-result" {
        inherit impureLlmResult;
        outputHashAlgo = "sha256";
        outputHash = pkgs.lib.hashFile "sha256" "${impureLlmResult}/extracted-data.json"; # Hash the actual content
      } ''
        mkdir -p $out
        cp -r "${impureLlmResult}"/* $out/
      '';

      # Optionally, archive the pure result into a NAR using our nar-bridge-flake
      archivedPureLlmResult = narBridgeFlake.lib.createNar {
        name = "pure-llm-result-nar";
        path = pureLlmResult;
      };
    in
    {
      packages.aarch64-linux.default = pureLlmResult;
      packages.aarch64-linux.narArchive = archivedPureLlmResult;
    };
}