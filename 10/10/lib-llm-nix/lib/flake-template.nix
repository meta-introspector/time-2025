# statix: ignore
# This file is a Nix flake template generator, not a standalone flake.
# It constructs a flake expression using string concatenation, which statix
# cannot correctly analyze.
{ lib, pkgs, flakeSource, inputFlakes, processFlakes, outputFlakes }:

# This function takes 'constants' for partial evaluation and returns a pure runnable Nix flake expression.
{ constants }:

{
  description = "Derived LLM Task Flake (Partial Application)";

  inputs = {
    nixpkgs.url = flakeSource;
  } // (pkgs.lib.genAttrs inputFlakes (f: { url = f; }))
    // (pkgs.lib.genAttrs processFlakes (f: { url = f; }))
    // (pkgs.lib.genAttrs outputFlakes (f: { url = f; }));

  outputs = inputs@{ self, nixpkgs, ... }:
    let
      system = "x86_64-linux"; # Hardcode system for now
      pkgs = import nixpkgs { inherit system; };
      taskParameters = constants; # Use the passed constants for partial evaluation
    in
    {
      defaultPackage.${system} = pkgs.runCommand "derived-llm-task" {} ''
        echo "Building derived LLM task (partial application)..." > "$out"
        echo "This derived flake represents a partial application with holes." >> "$out"
        echo "Input Patterns: ${pkgs.lib.concatStringsSep ", " inputFlakes}" >> "$out"
        echo "Process Patterns: ${pkgs.lib.concatStringsSep ", " processFlakes}" >> "$out"
        echo "Outputs: ${pkgs.lib.concatStringsSep ", " outputFlakes}" >> "$out"
        echo "To fully instantiate, parameters like taskParameters would be applied." >> "$out"
        # Example of how an input pattern might be used (conceptual):
        # ${inputs.input-llm-inputs.defaultPackage.${system}.fillHoles taskParameters}
        # Placeholder for actual LLM task logic using instantiated inputs, processes, and outputs
      '';
    };
}