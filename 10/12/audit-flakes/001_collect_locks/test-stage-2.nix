{ pkgs ? import <nixpkgs> { }, lib ? pkgs.lib, system ? builtins.currentSystem }:

let
  bagOfWordsGeneratorPath = /data/data/com.termux.nix/files/home/pick-up-nix2/source/github/meta-introspector/streamofrandom/2025/flakes/bag-of-words-generator;
  flakePath = /data/data/com.termux.nix/files/home/pick-up-nix2/source/github/meta-introspector/streamofrandom/2025/flake.nix;

  bagOfWordsGenerator = import bagOfWordsGeneratorPath { inherit pkgs lib system; };
in

toString (bagOfWordsGenerator.lib.${system}.generateBagOfWords flakePath)
