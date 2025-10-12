{ lib, pkgs, flakeSource, inputFlakes, processFlakes, outputFlakes, constants ? { } }:

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
      defaultPackage.${system} = pkgs.writeText "derived-llm-task-info.txt" ''
        Building derived LLM task (partial application)...
        This derived flake represents a partial application with holes.
        Input Patterns: ${pkgs.lib.concatStringsSep ", " inputFlakes}
        Process Patterns: ${pkgs.lib.concatStringsSep ", " processFlakes}
        Outputs: ${pkgs.lib.concatStringsSep ", " outputFlakes}
        To fully instantiate, parameters like taskParameters would be applied.
        # Placeholder for actual LLM task logic using instantiated inputs, processes, and outputs
      '';
    };
}
