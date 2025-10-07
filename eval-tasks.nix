{ pkgs ? import <nixpkgs> {} }:

let
  tasks = import ./generate-derivations.nix { inherit (pkgs) lib; };
in
pkgs.runCommand "generated-tasks" {} ''
  for task in $tasks; do
    echo "$task" >> $out
  done
''
