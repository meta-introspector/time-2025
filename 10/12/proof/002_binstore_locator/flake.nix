{
  description = "A flake to locate and copy the NAR file to the binstore.";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
    flake-utils.url = "github:meta-introspector/flake-utils?ref=feature/CRQ-016-nixify";
    nar-exporter-flake.url = "path:../001_nar_exporter"; # Input from Layer 2
  };

  outputs = { self, nixpkgs, flake-utils, nar-exporter-flake }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        astNarFile = nar-exporter-flake.packages.${system}.default;
      in
      {
        packages.default = pkgs.runCommand "binstore-nar-locator"
          {
            nativeBuildInputs = [ pkgs.coreutils ]; # For cp
            narFile = astNarFile;
            binstorePath = "${toString ../../binstore}"; # The binstore directory
          } ''
          mkdir -p $out
          cp $narFile/ast.nar $binstorePath/ast.nar
          echo "NAR file copied to $binstorePath/ast.nar" > $out/result.txt
        '';
      }
    );
}
