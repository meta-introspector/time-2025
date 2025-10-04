{ pkgs ? import <nixpkgs> {} }:

let
  # Select a few simple attributes from pkgs for a simplified dump
  simplifiedPkgs = {
    system = pkgs.system;
    nixpkgsVersion = builtins.toString pkgs.lib.version;
    # Add other simple attributes as needed for debugging
    # For example, if you need to inspect a specific package's name:
    # helloName = pkgs.hello.name; # This might trigger evaluation
  };

in
simplifiedPkgs
