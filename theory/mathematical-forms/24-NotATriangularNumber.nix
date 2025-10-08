{ lib, ... }:
let
  common = import ./_common.nix { inherit lib; };
  inherit (common) n;
in
! (lib.elem n (lib.map (i: i * (i + 1) / 2) (lib.range 1 10)))