{ pkgs ? import <nixpkgs> { }, lib ? pkgs.lib }:

pkgs.callPackage ./mypackage.nix { }
