{ lib, ... }:
let
  common = import ./_common.nix { inherit lib; };
  inherit (common) n primesUpTo31;
in
"31 is the " + (toString (lib.length (lib.filter (p: p <= n) primesUpTo31))) + "th prime number."
