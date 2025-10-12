{ lib, ... }:
let
  common = import ./_common.nix { inherit lib; };
  inherit (common) n;
in
16 * 16 - 15 * 15 == n
