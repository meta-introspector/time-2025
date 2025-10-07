{ lib, ... }:
let
  common = import ./_common.nix { inherit lib; };
  inherit (common) isHappy n;
in
isHappy n