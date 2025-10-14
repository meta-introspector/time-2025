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
            testScript = collect_locks_flake.test_flake_sh; # Access as a top-level attribute
          } ''
          # Execute the test script
          bash $testScript
        '';
      });
}
