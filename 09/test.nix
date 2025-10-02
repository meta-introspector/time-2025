# test.nix - Temporary file for FOAF-OWL verification testing
let
  common = import ../lib/common-imports.nix {};
  pkgs = common.pkgs;
  lib = common.lib;
  builtins = common.builtins;

  # Mock self for foaf.nix import, as it expects self
  # This is a workaround for direct evaluation outside a flake context
  mockSelf = { outPath = "/data/data/com.termux.nix/files/home/pick-up-nix2/source/github/meta-introspector/streamofrandom/2025/09"; };

  # Import the FOAF data
  foafData = import ./foaf.nix { inherit pkgs; self = mockSelf; };

  # Import the OWL schema
  owlSchema = import ./owl.nix { inherit pkgs lib; };

  # Import the verification logic
  verifyFoafOwl = import ./verify-foaf-owl.nix { inherit pkgs lib foafData owlSchema; };
in
verifyFoafOwl.validationResults
