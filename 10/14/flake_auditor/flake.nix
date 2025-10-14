{
  description = "Nix flake for flake_auditor Rust crate";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
    flake-utils.url = "github:meta-introspector/flake-utils?ref=feature/CRQ-016-nixify";
    naersk.url = "github:meta-introspector/naersk?ref=feature/CRQ-016-nixify";
  };

  outputs = { self, nixpkgs, flake-utils, naersk }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        naersk-lib = pkgs.callPackage naersk { };
        src = pkgs.lib.cleanSource ./.; # Define src here
      in
      {
        packages.flake-auditor = naersk-lib.buildPackage {
          pname = "flake-auditor";
          version = "0.1.0"; # Matches Cargo.toml
          inherit src; # Use the defined src
          cargoLock = builtins.path { path = ./Cargo.lock; };
          root = ".";
        };

        defaultPackage = self.packages.${system}.flake-auditor;

        devShell = pkgs.mkShell {
          buildInputs = with pkgs; [
            rustc
            cargo
            rustfmt
            clippy
          ];
        };
      });
}
