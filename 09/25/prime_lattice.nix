# prime_lattice.nix
# Defines the initial lattice for our prime-based language,
# mapping the first 8 primes to their bott vibes, Brainf* operations, and emoji representations.

{
  # The base language: first 8 primes
  primes = builtins.listToAttrs (
    builtins.map
      (file: {
        name = builtins.substring 6 (builtins.stringLength file - 10) file; # Extract prime number from filename (e.g., "prime_2.nix" -> "2")
        value = import (./primes + "/${file}");
      })
      (builtins.attrNames (builtins.readDir ./primes))
  );

  # Placeholder for higher-ordered primes and their lattice connections
  higherPrimes = { };
  latticeConnections = { };
}
