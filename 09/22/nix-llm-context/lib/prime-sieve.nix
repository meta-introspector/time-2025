# nix-llm-context/lib/prime-sieve.nix
# Implements a basic Sieve of Eratosthenes in Nix

{ lib }:

let
  # Function to generate a list of numbers from 2 to n
  range = n: lib.genList (i: i + 2) (n - 1);

  # Sieve function
  sieve = numbers:
    if lib.length numbers == 0 then [ ]
    else
      let
        p = lib.head numbers;
        # Filter out multiples of p
        filtered = lib.filter (n: (n % p) != 0) (lib.tail numbers);
      in
      [ p ] ++ (sieve filtered);

  # Main prime sieve function
  primeSieve = n:
    if n < 2 then [ ]
    else sieve (range n);

in
primeSieve
