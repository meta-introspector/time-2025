{ lib, n, ... }:
{
  # Properties related to Prime 13 (Integration/Correlation)
  "10-DifferenceOfSquares" = (16 * 16 - 15 * 15 == n);
  "11-SumOfFourPrimes" = (2 + 3 + 7 + 19 == n);
  "12-NumberOfDivisors" = 2; # 1 and 31
  "13-SumOfDivisors" = 1 + n;
  "27-SumOfTwoPrimes" = "31 = 2 + 29";
  "28-SumOfThreePrimes" = "31 = 3 + 5 + 23 or 3 + 11 + 17 or 5 + 7 + 19 or 5 + 13 + 13";
  "29-SumOfDistinctPrimes" = "31 = 2 + 3 + 7 + 19";
}