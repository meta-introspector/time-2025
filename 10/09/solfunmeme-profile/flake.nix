
# 10/09/solfunmeme-profile/flake.nix
{ 
  description = "Nix flake to fetch the solfunmeme profile page from Colosseum Arena.";

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
        solfunmemeProfileUrl = "https://arena.colosseum.org/profiles/solfunmeme";
      in
      {
        packages.solfunmeme-profile = pkgs.stdenv.mkDerivation {
          pname = "solfunmeme-profile";
          version = "0.1.0";
          dontUnpack = true;
          src = pkgs.fetchurl {
            url = solfunmemeProfileUrl;
            # Placeholder sha256, will be updated after first build failure.
            sha256 = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
          };
          installPhase = ''
            mkdir -p $out
            cp $src $out/index.html
          '';
        };
      }
    );
}
