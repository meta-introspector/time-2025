{
  description = "A development environment for Rust code generation with Gemini.";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
    flake-utils.url = "github:meta-introspector/flake-utils?ref=feature/CRQ-016-nixify";
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            rustc
            cargo
            rust-analyzer
            # Add any other Rust-related tools or libraries needed for code generation
          ];

          # Environment variables for Rust development
          RUST_SRC_PATH = "${pkgs.rustPlatform.rustLibSrc}";

          # Placeholder for self-sources and data needed by Gemini
          # This will be populated dynamically or through other Nix mechanisms
          # GEMINI_RUST_EXAMPLES = "${self}/examples/rust";
          # GEMINI_RUST_DATA = "${self}/data/rust";
        };
      });
}
