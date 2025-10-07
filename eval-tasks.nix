{ pkgs ? import <nixpkgs> {} }:

let
  monadContext = import ./lib/monad-context.nix { inherit pkgs lib; geminiApi = {}; };
  # Import the list of task attribute sets
  tasks = monadContext.generateTasks;

  # Process each task and collect the derivation paths
  generatedDerivations = lib.map monadContext.processTask tasks;
in
pkgs.runCommand "generated-derivations-output" {
  buildInputs = [ pkgs.coreutils ];
} ''
  for drvPath in ${lib.concatStringsSep " " generatedDerivations}; do
    echo "$drvPath" >> $out
  done
''
