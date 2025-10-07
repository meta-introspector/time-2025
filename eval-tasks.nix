{ pkgs ? import <nixpkgs> {} }:

let
  tasks = import ./generate-derivations.nix { inherit (pkgs) lib; };
  # Convert the Nix list of strings to a single string with newlines
  tasksString = pkgs.lib.concatStringsSep "\n" tasks;
in
pkgs.runCommand "generated-tasks" {} ''
  echo "${tasksString}" > "$out"
''
