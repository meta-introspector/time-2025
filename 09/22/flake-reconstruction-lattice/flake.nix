{
  description = "Experimental flake reconstructing dependencies from flake.lock";

  inputs = {
    flake-utils.url = "github:meta-introspector/flake-utils?ref=feature/CRQ-016-nixify";
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
    rust-overlay.url = "github:meta-introspector/rust-overlay?ref=feature/CRQ-016-nixify";
    template-generator-bin.url = "github:meta-introspector/time-2025/feature/foaf?dir=tools/template_generator_bin";
  };

  outputs = { nixpkgs, flake-utils, rust-overlay }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ rust-overlay.overlays.default ];
        };
      in
      {
        devShell = pkgs.mkShell {
          buildInputs = [
            pkgs.git
            pkgs.nix
            pkgs.bash
            pkgs.coreutils
            pkgs.jq
            pkgs.gh
            pkgs.shellcheck
            pkgs.curl
            pkgs.pandoc
          ];
        };

        packages.crqNumber = pkgs.runCommand "crq-number-derivation" { } ''
          echo "808017424794512875886459904961710757005754368000000000" > $out
        '';
      }
    );
}
