{ lib, ... }:
let
  common = import ./_common.nix { inherit lib; };
  inherit (common) n;
in
2 + 3 + 7 + 19 == n
