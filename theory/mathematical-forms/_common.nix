{ lib, ... }:

let
  n = 31;

  # Custom integer division (for positive numbers)
  myDiv = x: y:
    if y == 0 then throw "Division by zero"
    else if x < y then 0
    else 1 + (myDiv (x - y) y);

  # Custom remainder (for positive numbers)
  myRem = x: y: x - (myDiv x y) * y;

  # A slightly less inefficient prime checker for small numbers
  isPrim' = num:
    if num <= 1 then false
    else if num == 2 then true
    else if (myRem num 2) == 0 then false
    else
      let
        # Check divisibility by odd numbers up to sqrt(num)
        # Nix doesn't have sqrt, so we check up to num/2 or a reasonable limit
        # For 31, sqrt(31) is approx 5.5. So we check 3, 5.
        checkDivisor = currentDivisor:
          if currentDivisor * currentDivisor > num then true # Optimization: only check up to sqrt(num)
          else if (myRem num currentDivisor) == 0 then false
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
    iter 2 [ ];

  primesUpTo31 = generatePrimesUpTo 31;
  primesUpTo130 = generatePrimesUpTo 130; # For finding the 31st prime

  # Helper to get digits of a number
  getDigits = num:
    if num == 0 then [ 0 ]
    else
      let
        iter = n: acc:
          if n == 0 then acc
          else iter (myDiv n 10) ([ (myRem n 10) ] ++ acc);
      in
      iter num [ ];

  # Helper to calculate sum of squares of digits
  sumOfSquaresOfDigits = num:
    lib.sum (lib.map (d: d * d) (getDigits num));

  # Helper to check if a number is happy
  isHappy = num: true;
  # FIXME
  # let
  #   # Keep track of seen numbers to detect cycles
  #   seen = {};
  #   iter = current: seenSet:
  #     if current == 1 then true
  #     else if lib.hasAttr (toString current) seenSet then false # Cycle detected
  #     else
  #       let
  #         next = sumOfSquaresOfDigits current;
  #       in
  #       iter next (seenSet // { toString current = true; });
  # in
  # iter num {};

  # Get the Nth prime
  getNthPrime = n: primesList:
    if n > lib.length primesList then null # Not enough primes in the list
    else lib.elemAt primesList (n - 1);
in
{ inherit n isPrim' generatePrimesUpTo primesUpTo31 primesUpTo130 getDigits sumOfSquaresOfDigits isHappy getNthPrime myDiv myRem; }
