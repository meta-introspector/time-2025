{ lib, n, ... }:
{
  # Properties related to Prime 2 (Duality/Foundation)
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

  "02-IsPrime" = isPrim' n;
  "20-ConsecutivePrimeGap" = n - 29 == 2; # Related to prime sequence
}
