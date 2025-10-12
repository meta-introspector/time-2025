{
  description = "Nix flake to mirror the Colosseum website.";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
    flake-utils.url = "github:meta-introspector/flake-utils?ref=feature/CRQ-016-nixify";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };
        colosseumUrl = "https://colosseum.com";
      in
      {
        packages.colosseum-mirror = pkgs.stdenv.mkDerivation {
          pname = "colosseum-mirror";
          version = "0.1.0";

          src = pkgs.fetchurl {
            url = colosseumUrl;
            sha256 = "cFDRewMK87as/u4zvtrKdxwEmSyaSH/M0Buq20Gb3zU=";
          };

          dontUnpack = true;

          installPhase = ''
            mkdir -p $out
            cp $src $out/index.html
          '';
        };

        # A devShell to provide tools for working with the mirror
        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            httrack # For more advanced mirroring
            wget # Another tool for fetching
          ];
        };
      }
    );
}
