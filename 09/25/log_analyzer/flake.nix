{
  description = "Nix flake for the log_analyzer Rust project";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
    flake-utils.url = "github:meta-introspector/flake-utils?ref=feature/CRQ-016-nixify";
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      {
        packages.default = pkgs.rustPlatform.buildRustPackage rec {
          pname = "log-analyzer";
          version = "0.1.0";

          src = ./.;

          cargoLock = {
            # This assumes a Cargo.lock exists in the src directory
            lockFile = ./Cargo.lock;
          };

          # Add any build inputs required by the Rust project
          buildInputs = [
            # pkgs.openssl # Example if openssl is needed
          ];

          # Optional: Add checkPhase if there are tests
          # checkPhase = "cargo test";
        };
      }
    );
}
