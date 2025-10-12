{ pkgs ? import <nixpkgs> { } }:

let
  # Import the test case data
  testCase = import ./test-commit-check/test-case-crq-041.nix { };
  inherit (testCase) commitMsg;

  # Import the regex generator
  regex = import ./regex-generator.nix { inherit pkgs; };

  # Import the check logic
  isValid = import ./test-commit-check/check-logic.nix { inherit pkgs commitMsg regex; };

in
if isValid then
  import ./test-commit-check/success-derivation.nix { inherit pkgs; }
else
  import ./test-commit-check/failure-derivation.nix { inherit pkgs commitMsg regex; }
