{ lib, pkgs, nixLogParserModule }:



let
  logString = ''
    building /nix/store/abcd1234efgh-my-package-1.0.drv
    installing /nix/store/ijkl5678mnop-another-package-2.0
    some other log line
    fetching /nix/store/qrst9012uvwx-yet-another-package-3.0.tar.gz
  '';

  expectedPaths = [
    "/nix/store/abcd1234efgh-my-package-1.0.drv"
    "/nix/store/ijkl5678mnop-another-package-2.0"
    "/nix/store/qrst9012uvwx-yet-another-package-3.0.tar.gz"
  ];

  extractedPaths = nixLogParserModule.extractNixStorePathsFromLog (lib.strings.splitString "\n" logString);

  # Simple assertion to check if the extracted paths match the expected paths
  # This might need more sophisticated comparison for order-independent lists
  testResult = lib.lists.subtractLists expectedPaths extractedPaths == [] &&
               lib.lists.subtractLists extractedPaths expectedPaths == [];

in
{
  name = "test-nix-log-parser";
  value = testResult;
  inherit extractedPaths;
  inherit expectedPaths;
}
