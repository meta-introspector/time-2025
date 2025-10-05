{ lib, n, ... }:
{
  # Properties related to Prime 17 (Refinement/Communication)
  "03-MersennePrimeExponent" = "31 is a prime 'p' such that 2^p - 1 (2^31 - 1) is a Mersenne prime.";
  "04-CenteredPentagonalNumber" = (n == (5 * 4 * 4 - 5 * 4 + 2) / 2); # For n=4, P_4 = 31
}