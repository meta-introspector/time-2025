let
  pkgs = import <nixpkgs> {};
  result = import ./default.nix { inherit pkgs; };
in
result
