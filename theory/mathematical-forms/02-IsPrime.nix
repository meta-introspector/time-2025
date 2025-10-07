{ lib, ... }:
let
  common = import ./_common.nix { inherit lib; };
  inherit (common) isPrim' n;
in
isPrim' n