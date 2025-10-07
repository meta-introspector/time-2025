{ lib, ... }:
let
  common = import ./_common.nix { inherit lib; };
  inherit (common) n;
in
"31 = 3 + 5 + 23 or 3 + 11 + 17 or 5 + 7 + 19 or 5 + 13 + 13"