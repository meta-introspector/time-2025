{
  description = "A Nix-flake for the log_analyzer Rust project";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
    flake-utils.url = "github:numtide/flake-utils";
    ai-ml-zk-ops.url = "github:meta-introspector/ai-ml-zk-ops?ref=feature/concept-to-nix-8s";
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        lib = nixpkgs.lib;
        src = lib.cleanSource ./.;
        cargoDeps = pkgs.rustPlatform.fetchCargoVendor {
          inherit src;
          lockFile = ./Cargo.lock;
          hash = "sha256-4OfBA/qEEfO/yKAUWVmKkPc2hGbi3GfTMFfyvpipBt8=";
        };
      in
      {
        packages.log-analyzer = pkgs.rustPlatform.buildRustPackage {
          pname = "log-analyzer";
          version = "0.1.0";
          src = ./.;
          inherit cargoDeps;
          nativeBuildInputs = with pkgs; [
            pkg-config
            openssl
          ];
          buildInputs = with pkgs; [
            # Add any runtime dependencies here if necessary
          ];
        };

        packages.default = self.packages.${system}.log-analyzer;

        devShells.default = pkgs.mkShell {
          inputsFrom = [ self.packages.${system}.log-analyzer ];
          packages = with pkgs; [
            rustc
            cargo
            rustfmt
            clippy
            # Add any other development tools here
          ];
          RUST_SRC_PATH = "${pkgs.rustPlatform.rustLibSrc}";
        };
      }
    );
}