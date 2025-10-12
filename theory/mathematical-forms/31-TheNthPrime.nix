{ lib, ... }:
let
  common = import ./_common.nix { inherit lib; };
  inherit (common) n getNthPrime primesUpTo130;
  nthPrime = getNthPrime n primesUpTo130;
  nStr = toString n;
  nthPrimeStr = toString nthPrime;
in
"The ${nStr}th prime number is ${nthPrimeStr}."
