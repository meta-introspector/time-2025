{ lib, ... }:
let
  common = import ./_common.nix { inherit lib; };
  inherit (common) n;
in
"31 is an emirp because 13 (its digit reversal) is prime and 13 != 31."
