{ lib, ... }:
let
  common = import ./_common.nix { inherit lib; };
  inherit (common) n;
in
n == (5 * 4 * 4 - 5 * 4 + 2) / 2