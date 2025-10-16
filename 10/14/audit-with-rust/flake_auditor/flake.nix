{
  description = "Nix flake for the Rust flake_auditor tool.";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
    flake-utils.url = "github:meta-introspector/flake-utils?ref=feature/CRQ-016-nixify";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        packages.default = pkgs.rustPlatform.buildRustPackage {
          pname = "nix_auditor_rust";
          version = "0.1.0";
          src = ./.;
          cargoLock = { inherit (self) src; }; # Use the Cargo.lock from this directory

          # Ensure the binary is installed to bin
          installPhase = ''
            mkdir -p $out/bin
            cp $cargoBuildDir/release/nix_auditor_rust $out/bin
          '';
        };

        apps.default = {
          type = "app";
          program = "${self.packages.${system}.default}/bin/nix_auditor_rust";
        };
      }
    );
}
