{ pkgs ? import <nixpkgs> {} }:

pkgs.runCommand "number-23" {} ''
  echo "23" > $out/number
''
