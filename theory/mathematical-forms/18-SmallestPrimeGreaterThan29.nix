{ lib, ... }:
let
  common = import ./_common.nix { inherit lib; };
  inherit (common) n primesUpTo31;
in
lib.head (lib.filter (p: p > 29) primesUpTo31) == n