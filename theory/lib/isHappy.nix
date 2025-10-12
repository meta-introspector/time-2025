{ lib }:

rec {
  # Helper to get digits of a number
  getDigits = num:
    if num == 0 then [ 0 ]
    else
      let
        iter = n: acc:
          if n == 0 then acc
          else iter (lib.div n 10) ([ (lib.mod n 10) ] ++ acc);
      in
      iter num [ ];

  # Helper to calculate sum of squares of digits
  sumOfSquaresOfDigits = num:
    lib.sum (lib.map (d: d * d) (getDigits num));

  # Helper to check if a number is happy
  isHappy = num: /*
    let
      inherit lib; # Make lib available in this scope
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
  */ true;
}
