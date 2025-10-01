{
  description = "A Nix-flake for the log_analyzer Rust project";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
    flake-utils.url = "github:meta-introspector/flake-utils?ref=feature/CRQ-016-nixify";
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
          hash = "sha256-dtmB3Ve6dMwS2XfP91U9R1E82flxSuu3ySUM33O/3zs=";
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
          env = {
            PKG_CONFIG_PATH = "${pkgs.openssl.dev}/lib/pkgconfig";
          };
        };

        packages.hello = pkgs.writeShellScriptBin "hello" ''
          echo "hello"
        '';

        packages.default = self.packages.${system}.log-analyzer;

        devShells.default = pkgs.mkShell {
          inputsFrom = [ self.packages.${system}.log-analyzer ];
          packages = with pkgs; [
            rustc
            cargo
            rustfmt
            clippy
            openssl
            # Add any other development tools here
          ];
          RUST_SRC_PATH = "${pkgs.rustPlatform.rustLibSrc}";
        };
      }
    );
}
