{ lib, n, isPrim', ... }:
{
  # Properties related to Prime 7 (Insight/Guidance)
  # Generate primes up to a limit (still inefficient for large limits)
  generatePrimesUpTo = limit:
    let
      iter = current: acc:
        if current > limit then acc
        else if isPrim' current then iter (current + 1) (acc ++ [ current ])
        else iter (current + 1) acc;
    in
    iter 2 [];

  primesUpTo31 = generatePrimesUpTo 31;
  primesUpTo130 = generatePrimesUpTo 130; # For finding the 31st prime

  # Get the Nth prime
  getNthPrime = n: primesList:
    if n > lib.length primesList then null # Not enough primes in the list
    else lib.elemAt primesList (n - 1);

  "08-PrimeIndex" = "31 is the " + (toString (lib.length (lib.filter (p: p <= n) primesUpTo31))) + "th prime number."; # 11th prime
  "09-PrimeIndexIsPrime" = isPrim' (lib.length (lib.filter (p: p <= n) primesUpTo31)); # 11 is prime
  "18-SmallestPrimeGreaterThan29" = (lib.head (lib.filter (p: p > 29) primesUpTo31) == n);
  "19-LargestPrimeLessThan37" = (lib.last (lib.filter (p: p < 37) primesUpTo31) == n);
  "31-TheNthPrime" = "The " + (toString n) + "th prime number is " + (toString (getNthPrime n primesUpTo130)) + "."; # The 31st prime is 127
}