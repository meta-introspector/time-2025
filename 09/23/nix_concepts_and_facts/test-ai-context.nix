{ pkgs ? import <nixpkgs> { }, lib ? pkgs.lib
, concepts ? { number-23 = pkgs.writeText "dummy-number-23" "23"; is-prime-23 = pkgs.writeText "dummy-is-prime-23" "true"; fact-23-oracle = pkgs.writeText "dummy-fact-23-oracle" "fact"; }
, zos ? let
    primesList = import ./primes.nix;
    dummyZosPrimes = builtins.listToAttrs (builtins.map
      (prime: {
        name = "prime-${builtins.toString prime}";
        value = pkgs.writeText "dummy-prime-${builtins.toString prime}" "${builtins.toString prime}";
      })
      primesList);
  in
  { zosPrimes = dummyZosPrimes; }
, nixLib ? pkgs.lib
}:

let
  aiContext = import ./lib/ai-context.nix { inherit pkgs lib concepts zos nixLib; };
in
aiContext
