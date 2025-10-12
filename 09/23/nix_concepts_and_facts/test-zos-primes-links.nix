{ pkgs ? import <nixpkgs> { }
, lib ? pkgs.lib
, zos ? let
    primesList = [ 2 3 5 7 11 13 17 19 23 29 31 41 47 59 71 ];
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
  primesList = [ 2 3 5 7 11 13 17 19 23 29 31 41 47 59 71 ]; # Use the actual list of primes
  zosPrimesLinks = pkgs.lib.concatStringsSep "\n" (builtins.map
    (prime:
      ''ln -s ${zos.zosPrimes."prime-${builtins.toString prime}"}/primes.txt /tmp/concepts/zos_primes_${builtins.toString prime}.txt''
    )
    primesList);
in
zosPrimesLinks
