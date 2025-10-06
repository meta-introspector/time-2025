
# test_prime_encoder.nix
# Tests the prime_encoder.nix by encoding a SimpleExpr from MicroLean4.

{ pkgs ? import <nixpkgs> {}, lib ? pkgs.lib }:

let
  # Reference to the current flake (assuming this is run within a flake)
  self = builtins.getFlake (toString ./.) ;

  # Import our prime lattice
  primeLattice = import ./prime_lattice.nix;

  # Path to the SimpleExpr JSON file
  simpleExprJsonPath = self + "/10/05/MicroLean4/SimpleExpr.rec_686e510a6699f2e1ff1b216c16d94cd379ebeca00c030a79a3134adff699e06c.json";

  # Import the JSON reader
  readSimpleExprJsonModule = import ../lib/read_simple_expr_json.nix { inherit lib simpleExprJsonPath; };
  inherit (readSimpleExprJsonModule) readSimpleExprJson;

  # Import the prime encoder
  inherit (primeEncoderModule) encodeSimpleExpr;

  # Get the SimpleExpr object
  simpleExprObject = readSimpleExprJson;

  # Encode the SimpleExpr
  encodedPrimes = encodeSimpleExpr simpleExprObject;

in
  # Output the encoded primes for inspection
  encodedPrimes
