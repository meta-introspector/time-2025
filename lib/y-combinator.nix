
# lib/y-combinator.nix
# A template for a recursion function using a Y-combinator in Nix.

# The Y-combinator itself
# Y = λf.(λx.f(x x))(λx.f(x x))
# In Nix, we can approximate this using a fixed-point combinator.
# This version is a Z-combinator (strict Y-combinator) which works in strict languages like Nix.
{ lib, ... }:

let
  # Z-combinator (strict Y-combinator)
  # It takes a function 'f' that expects itself as its first argument.
  # f: (self: arg -> result) -> (arg -> result)
  zCombinator = f:
    let
      g = x: f (x x);
    in
    g g;

  # Example usage: Factorial function
  # We define 'factGen' which takes 'self' (the recursive function itself)
  # and returns a function that calculates factorial.
  factorialGenerator = self: n:
    if n == 0 then 1
    else n * (self (n - 1));

  # Apply the Z-combinator to our factorialGenerator to get the recursive factorial function
  factorial = zCombinator factorialGenerator;

  # Another example: Fibonacci sequence
  fibonacciGenerator = self: n:
    if n <= 1 then n
    else (self (n - 1)) + (self (n - 2));

  fibonacci = zCombinator fibonacciGenerator;

in
{
  inherit zCombinator factorial factorialGenerator fibonacci fibonacciGenerator;
}
