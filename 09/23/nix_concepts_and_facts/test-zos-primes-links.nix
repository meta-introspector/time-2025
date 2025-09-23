{ pkgs ? import <nixpkgs> {}, 
  zos ? { zosPrimes = { "prime-2" = pkgs.writeText "dummy-prime-2" "2"; }; }, 
  nixLib ? pkgs.lib 
}:

let
  primesList = [ 2 3 5 7 11 13 17 19 23 29 31 41 47 59 71 ]; # Use the actual list of primes
  zosPrimesLinks = pkgs.lib.concatStringsSep "\n" (builtins.map (prime: 
    ''ln -s ${zos.zosPrimes."prime-${builtins.toString prime}"}/primes.txt /tmp/concepts/zos_primes_${builtins.toString prime}.txt''
  ) primesList);
in
zosPrimesLinks
