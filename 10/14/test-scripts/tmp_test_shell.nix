{ pkgs ? import <nixpkgs> { }, lib ? pkgs.lib }:

pkgs.mkShell {
  buildInputs = with pkgs; [
    nix
    jq
    git
  ];
}
