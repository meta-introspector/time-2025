{ lib, ... }:
let
  common = import ./_common.nix { inherit lib; };
  inherit (common) n;
in
"31 is a prime 'p' such that 2^p - 1 (2^31 - 1) is a Mersenne prime."
