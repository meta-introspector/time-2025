{
  description = "Experimental flake reconstructing dependencies from flake.lock";

  inputs = {
    flake-utils.url = "github:meta-introspector/flake-utils?ref=feature/CRQ-016-nixify";
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
    rust-overlay.url = "github:meta-introspector/rust-overlay?ref=feature/CRQ-016-nixify";
    template-generator-bin.url = "path:/nix/store/qy5zixb912wm5hc7d0vmi8k76w1zl75g-source/tools/template_generator_bin";
  };

  outputs = { self, nixpkgs, flake-utils, rust-overlay, template-generator-bin }:
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
          ];
        };
      }
    );
}
