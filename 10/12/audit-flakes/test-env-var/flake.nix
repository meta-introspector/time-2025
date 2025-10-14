{
  description = "Temporary flake to test environment variable passing for flake inputs.";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
    bagOfWordsGenerator = {
      url = "github:meta-introspector/time-2025?ref=feature/aimyc-002-sample-extraction&dir=flakes/bag-of-words-generator";
      flake = true;
    };
  };

  outputs = { self, nixpkgs, bagOfWordsGenerator }:
    let
      pkgs = nixpkgs.legacyPackages.x86_64-linux; # Assuming x86_64-linux for testing
    in
    {
      packages.default = pkgs.runCommand "test-env-var"
        {
          BAG_OF_WORDS_FLAKE_INPUT = bagOfWordsGenerator; # Pass the flake input directly
        }
        ''
          mkdir -p $out
          echo "$BAG_OF_WORDS_FLAKE_INPUT" > $out/env-var-value.txt
        '';
    };
}
