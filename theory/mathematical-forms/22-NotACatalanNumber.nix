{ lib, ... }:
let
  common = import ./_common.nix { inherit lib; };
  inherit (common) n;
in
! (lib.elem n [ 1 2 5 14 42 ])