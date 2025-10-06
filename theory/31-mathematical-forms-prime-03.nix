{ lib, n }:

let
  isHappyModule = import ./lib/isHappy.nix { inherit lib; };
in
rec {
  "05-IsHappyNumber" = isHappyModule.isHappy n;
  # "06-PermutablePrime" = null;
  # "07-Emirp" = null;
}