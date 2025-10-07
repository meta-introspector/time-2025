{ pkgs ? import <nixpkgs> { }, lib ? pkgs.lib }:

let
  # Get the path to the directory containing this file
  currentDir = builtins.path { path = ./.; };
  factPath = "${currentDir}/../facts/fact_about_23.txt";
in

pkgs.runCommand "fact-23-oracle" { } ''
  cp ${factPath} $out/fact
''
