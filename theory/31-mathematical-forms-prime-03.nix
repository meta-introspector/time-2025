{ lib, n }:
{
  # Properties related to Prime 3 (Structure/Form)
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
          iter next (seenSet // { "${toString current}" = true; });
    in
    iter num {};

  "05-IsHappyNumber" = isHappy n;
  # "06-PermutablePrime" = null;
  # "07-Emirp" = null;
}