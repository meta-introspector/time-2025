{ pkgs ? import <nixpkgs> {} }:

let
  monadContext = import ./lib/monad-context.nix { inherit pkgs; inherit (pkgs) lib; geminiApi = import ./lib/gemini-api-wrapper.nix { inherit (pkgs) lib; }; };
  # Import the list of task attribute sets
  tasks = monadContext.generateTasks;

  # Process each task and collect the derivation paths
  generatedDerivations = pkgs.lib.map monadContext.processTask tasks;

  # Convert the list of derivation paths to a list of strings
  generatedDerivationStrings = pkgs.lib.map toString generatedDerivations;

in
generatedDerivations # Return the list of derivations directly
