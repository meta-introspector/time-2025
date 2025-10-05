{ lib, n, ... }:
{
  # Properties related to Prime 11 (Challenge/Verification)
  "21-NotAFibonacciNumber" = ! (lib.elem n [ 1 2 3 5 8 13 21 34 ]);
  "22-NotACatalanNumber" = ! (lib.elem n [ 1 2 5 14 42 ]);
  "23-NotAFactorial" = ! (lib.elem n [ 1 2 6 24 120 ]);
  "24-NotATriangularNumber" = ! (lib.elem n (lib.map (i: i * (i + 1) / 2) (lib.range 1 10)));
  "25-NotASquareNumber" = ! (lib.elem n (lib.map (i: i * i) (lib.range 1 10)));
  "26-NotACubeNumber" = ! lib.elem n (lib.map (i: i * i * i) (lib.range 1 10));
  "32-FixForCubeNumberCheck" = (import ./31-mathematical-forms-cube-number-check-fix.nix { inherit lib; }).fixedLine;
}