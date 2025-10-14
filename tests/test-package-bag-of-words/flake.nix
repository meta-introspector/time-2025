{
  description = "A test flake for the packageBagOfWords function.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    auditFlakes = {
      url = "github:meta-introspector/time-2025?ref=feature/aimyc-002-sample-extraction&dir=10/12/audit-flakes";
    };
  };

  outputs = { self, nixpkgs, flake-utils, auditFlakes }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        lib = pkgs.lib;

        # Sample flake.nix path to test with
        sampleFlakePath = "/data/data/com.termux.nix/files/home/pick-up-nix2/source/github/meta-introspector/streamofrandom/2025/flake.nix";

        # Call the packageBagOfWords function
        bagOfWordsResult = auditFlakes.outputs.${system}.lib.packageBagOfWords sampleFlakePath;
      in
      {
        packages.default = pkgs.runCommand "test-bag-of-words"
          {
            inherit bagOfWordsResult;
          }
          ''
            mkdir -p $out
            echo "$bagOfWordsResult" > $out/bag-of-words.json
          '';
      }
    );
}
