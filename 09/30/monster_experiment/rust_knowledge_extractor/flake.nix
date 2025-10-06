{
  description = "A Nix flake for the rust_knowledge_extractor, allowing impure network access.";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
    flake-utils.url = "github:meta-introspector/flake-utils?ref=feature/CRQ-016-nixify";
    naersk.url = "github:nix-community/naersk/master"; # Using standard naersk for now
  };

  outputs = { self, nixpkgs, flake-utils, naersk, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        inherit (nixpkgs) lib;
        src = builtins.path { path = ./.; };
      in
      {
        packages = {
          rust-knowledge-extractor = naersk.lib.${system}.buildPackage {
            pname = "rust-knowledge-extractor";
            version = "0.1.0";
            inherit src;
            # naersk handles cargoLock and cargoDeps internally
            nativeBuildInputs = with pkgs; [
              pkg-config
              openssl
            ];
            buildInputs = with pkgs; [
              # Add any runtime dependencies here if necessary
            ];
            env = {
              # PKG_CONFIG_PATH = "${pkgs.openssl.dev}/lib/pkgconfig";
            };
          };

          default = self.packages.${system}.rust-knowledge-extractor;

          creds-test = pkgs.runCommand "creds-test" {
            extra-sandbox-paths = [ "/creds=/data/data/com.termux.nix/files/home/current-month/27/7-concepts/creds/live" ];
          } ''
            mkdir -p $out
            cat /creds/google_accounts.json > $out/google_accounts.json
            echo "Credentials accessed successfully!" > $out/result.txt
          '';
        };

        devShells.default = pkgs.mkShell {
          # This devShell will allow impure operations (like network access)
          # when running `nix develop` and then `cargo run` or `rust-knowledge-extractor`.
          packages = with pkgs; [
            rustc
            cargo
            rustfmt
            clippy
            openssl
            # Add any other development tools here
          ];
          # Allow network access in the devShell
          shellHook = ''
            export RUST_BACKTRACE=1
            echo "Development shell for rust_knowledge_extractor. Network access is allowed."
          '';
        };
      }
    );
}
