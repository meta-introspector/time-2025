{
  description = "A flake to test the 001_collect_locks flake.";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
    flake-utils.url = "github:meta-introspector/flake-utils?ref=feature/CRQ-016-nixify";
    collect_locks_flake = {
      url = "path:."; # Reference to the current 001_collect_locks flake
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
  };

  outputs = { self, nixpkgs, flake-utils, collect_locks_flake }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        lib = pkgs.lib;
      in
      {
        checks.testFlakeSh = pkgs.runCommand "test-flake-sh"
          {
            nativeBuildInputs = [ pkgs.bash ];

            # Define test parameters
            NIX_FILE_PATH = "/data/data/com.termux.nix/files/home/pick-up-nix2/source/github/meta-introspector/streamofrandom/2025/flake.nix";
            lockFile = "/data/data/com.termux.nix/files/home/pick-up-nix2/source/github/meta-introspector/streamofrandom/2025/flake.lock";
            BAG_OF_WORDS_GENERATOR_PATH = "/data/data/com.termux.nix/files/home/pick-up-nix2/source/github/meta-introspector/streamofrandom/2025/flakes/bag-of-words-generator";

            runTestScript = collect_locks_flake.outputs.${system}.run_flake_sh_test_env; # Path to the test runner script
          } ''
          # Execute the test runner script with parameters as environment variables
          export NIX_FILE_PATH="$NIX_FILE_PATH"
          export lockFile="$lockFile"
          export BAG_OF_WORDS_GENERATOR_PATH="$BAG_OF_WORDS_GENERATOR_PATH"
          bash $runTestScript
        '';
      });
}
