{
  description = "Feature 19: Self Source Input - Demonstrates taking its own source code as input.";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
    flake-utils.url = "github:meta-introspector/flake-utils?ref=feature/CRQ-016-nixify";
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        inherit lib;

        # A derivation that simply outputs its own source code
        selfSourceDerivation = pkgs.stdenv.mkDerivation {
          pname = "self-source-output";
          version = "1.0";

          src = self; # The source of this flake itself

          buildPhase = ''
            mkdir -p $out
            cp -r $src/* $out/
            echo "✅ Copied own source code to $out/"
          '';

          installPhase = ''
            echo "Own source code available in $out/"
          '';
        };

      in
      {
        lib = {
          inherit selfSourceDerivation;
        };

        packages.default = pkgs.writeText "self-source-feature" "This flake demonstrates taking its own source code as input.";
      }
    );
}
