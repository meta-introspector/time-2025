{ lib, ... }:
let
  common = import ./_common.nix { inherit lib; };
  inherit (common) n;
in
  ! (lib.elem n [ 1 2 3 5 8 13 21 34 ])
