# cwm.nix - Nix-native CWM equivalent for FOAF-OWL verification
{ pkgs, lib, self, ... }:

let
  # Import the FOAF data
  foafData = import ./foaf.nix { inherit pkgs lib self; };

  # Import the OWL schema
  owlSchema = import ./owl.nix { inherit pkgs lib; };

  # Import the verification logic
  verifyFoafOwl = import ./verify-foaf-owl.nix { inherit pkgs lib foafData owlSchema; };

in {
  # Expose the verification results
  verificationResults = verifyFoafOwl.validationResults;
  inherit (verifyFoafOwl) overallStatus;

  # You can also expose a devShell to easily run the verification
  devShell = pkgs.mkShell {
    name = "cwm-verification-shell";
    inputsFrom = [ self ]; # Inherit inputs from the main flake
    packages = with pkgs; [
      # Add any tools needed for development or inspection here
    ];
    shellHook = ''
      echo "Welcome to the CWM verification shell!"
      echo "To run verification, evaluate: nix eval .#overallStatus"
      echo "To see detailed results, evaluate: nix eval .#verificationResults"
    '';
  };
}
