{ lib, ... }:
let
  common = import ./_common.nix { inherit lib; };
  inherit (common) n;
in
"31 is a permutable prime because 13 (its digit permutation) is also prime."