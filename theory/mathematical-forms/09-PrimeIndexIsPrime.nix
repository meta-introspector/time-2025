{ lib, ... }:
let
  common = import ./_common.nix { inherit lib; };
  inherit (common) isPrim' n primesUpTo31;
in
isPrim' (lib.length (lib.filter (p: p <= n) primesUpTo31))
