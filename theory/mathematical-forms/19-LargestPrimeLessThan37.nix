{ lib, ... }:
let
  common = import ./_common.nix { inherit lib; };
  inherit (common) n primesUpTo31;
in
lib.last (lib.filter (p: p < 37) primesUpTo31) == n