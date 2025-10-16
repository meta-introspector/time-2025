{
  description = "Nix flake for the Rust flake_auditor tool.";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
    flake-utils.url = "github:meta-introspector/flake-utils?ref=feature/CRQ-016-nixify";
    naersk.url = "github:meta-introspector/naersk?ref=feature/CRQ-016-nixify";
  };

  outputs = { self, nixpkgs, flake-utils, naersk }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        naersk-lib = pkgs.callPackage naersk { };
      in
      {
        packages.default = naersk-lib.buildPackage {
          pname = "nix_auditor_rust";
          version = "0.1.0";
          src = pkgs.lib.cleanSource ./.;
        };

        apps.default = {
          type = "app";
          program = "${self.packages.${system}.default}/bin/nix_auditor_rust";
        };
      }
    );
}
