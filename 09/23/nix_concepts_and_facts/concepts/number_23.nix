{ pkgs ? import <nixpkgs> { }, lib ? pkgs.lib }:

pkgs.runCommand "number-23" { } ''
  echo "23" > $out/number
''
