{ pkgs ? import <nixpkgs> { } }:

pkgs.callPackage ./mypackage.nix { }
