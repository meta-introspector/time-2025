# test.nix - Temporary file for FOAF-OWL verification testing
{ selfPath ? builtins.path { path = ./.; } }:

let
  common = import ../lib/common-imports.nix {};
  inherit (common) pkgs lib builtins;

  # Mock self for foaf.nix import, as it expects self
  # This is a workaround for direct evaluation outside a flake context
  mockSelf = { outPath = selfPath; };

  # Import the FOAF data
  foafData = import ./foaf.nix { inherit pkgs; self = mockSelf; };

  # Import the OWL schema
  owlSchema = import ./owl.nix { inherit pkgs lib; };

  # Import the verification logic
  verifyFoafOwl = import ./verify-foaf-owl.nix { inherit pkgs lib foafData owlSchema; };
in
verifyFoafOwl.validationResults
