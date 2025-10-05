# theory/31-mathematical-forms.nix
{ lib, ... }:

let
  n = 31;

  # A slightly less inefficient prime checker for small numbers
  isPrim' = num:
    if num <= 1 then false
    else if num == 2 then true
    else if num mod 2 == 0 then false
    else
      let
        # Check divisibility by odd numbers up to sqrt(num)
        # Nix doesn't have sqrt, so we check up to num/2 or a reasonable limit
        # For 31, sqrt(31) is approx 5.5. So we check 3, 5.
        checkDivisor = currentDivisor:
          if currentDivisor * currentDivisor > num then true # Optimization: only check up to sqrt(num)
          else if num mod currentDivisor == 0 then false
          else checkDivisor (currentDivisor + 2);
      in
      checkDivisor 3;

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

  # Helper to get digits of a number
  getDigits = num:
    if num == 0 then [ 0 ]
    else
      let
        iter = n: acc:
          if n == 0 then acc
          else iter (n div 10) ([ (n mod 10) ] ++ acc);
      in
      iter num [];

  # Helper to calculate sum of squares of digits
  sumOfSquaresOfDigits = num:
    lib.sum (lib.map (d: d * d) (getDigits num));

  # Helper to check if a number is happy
  isHappy = num:
    let
      # Keep track of seen numbers to detect cycles
      seen = {};
      iter = current: seenSet:
        if current == 1 then true
        else if lib.hasAttr (toString current) seenSet then false # Cycle detected
        else
          let
            next = sumOfSquaresOfDigits current;
          in
          iter next (seenSet // { (toString current) = true; });
    in
    iter num {};

  # Get the Nth prime
  getNthPrime = n: primesList:
    if n > lib.length primesList then null # Not enough primes in the list
    else lib.elemAt primesList (n - 1);

in
{
  "01-Value" = n;
  "02-IsPrime" = isPrim' n;
  "03-MersennePrimeExponent" = "31 is a prime 'p' such that 2^p - 1 (2^31 - 1) is a Mersenne prime.";
  "04-CenteredPentagonalNumber" = (n == (5 * 4 * 4 - 5 * 4 + 2) / 2); # For n=4, P_4 = 31
  "05-IsHappyNumber" = isHappy n;
  "06-PermutablePrime" = "31 is a permutable prime because 13 (its digit permutation) is also prime.";
  "07-Emirp" = "31 is an emirp because 13 (its digit reversal) is prime and 13 != 31.";
  "08-PrimeIndex" = "31 is the " + (toString (lib.length (lib.filter (p: p <= n) primesUpTo31))) + "th prime number."; # 11th prime
  "09-PrimeIndexIsPrime" = isPrim' (lib.length (lib.filter (p: p <= n) primesUpTo31)); # 11 is prime
  "10-DifferenceOfSquares" = (16 * 16 - 15 * 15 == n);
  "11-SumOfFourPrimes" = (2 + 3 + 7 + 19 == n);
  "12-NumberOfDivisors" = 2; # 1 and 31
  "13-SumOfDivisors" = 1 + n;
  "14-BinaryRepresentation" = "11111"; # 5 ones
  "15-HexadecimalRepresentation" = "1F";
  "16-OctalRepresentation" = "37";
  "17-NumberOfBits" = 5; # ceil(log2(31+1))
  "18-SmallestPrimeGreaterThan29" = (lib.head (lib.filter (p: p > 29) primesUpTo31) == n);
  "19-LargestPrimeLessThan37" = (lib.last (lib.filter (p: p < 37) primesUpTo31) == n);
  "20-ConsecutivePrimeGap" = (n - 29 == 2);
  "21-NotAFibonacciNumber" = ! (lib.elem n [ 1 2 3 5 8 13 21 34 ]);
  "22-NotACatalanNumber" = ! (lib.elem n [ 1 2 5 14 42 ]);
  "23-NotAFactorial" = ! (lib.elem n [ 1 2 6 24 120 ]);
  "24-NotATriangularNumber" = ! (lib.elem n (lib.map (i: i * (i + 1) / 2) (lib.range 1 10)));
  "25-NotASquareNumber" = ! (lib.elem n (lib.map (i: i * i) (lib.range 1 10)));
  "26-NotACubeNumber" = ! (lib.elem n (lib.map (i: i * i * i) (lib.range 1 10)));
  "27-SumOfTwoPrimes" = "31 = 2 + 29";
  "28-SumOfThreePrimes" = "31 = 3 + 5 + 23 or 3 + 11 + 17 or 5 + 7 + 19 or 5 + 13 + 13";
  "29-SumOfDistinctPrimes" = "31 = 2 + 3 + 7 + 19";
  "30-NumberInSomeMonths" = "31 is the number of days in January, March, May, July, August, October, December.";
  "31-TheNthPrime" = "The " + (toString n) + "th prime number is " + (toString (getNthPrime n primesUpTo130)) + "."; # The 31st prime is 127
}
