{ lib, ... }:
let
  common = import ./_common.nix { inherit lib; };
  inherit (common) n;
in
"31 is the number of days in January, March, May, July, August, October, December."
