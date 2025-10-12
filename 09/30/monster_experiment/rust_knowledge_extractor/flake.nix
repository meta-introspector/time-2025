{
  description = "A Nix flake for the rust_knowledge_extractor, allowing impure network access.";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
    flake-utils.url = "github:meta-introspector/flake-utils?ref=feature/CRQ-016-nixify";
    naersk.url = "github:nix-community/naersk/master"; # Using standard naersk for now
    sops-nix.url = "github:meta-introspector/sops-nix?ref=feature/working-gemini-cli-nix-store";
  };

  outputs = { self, nixpkgs, flake-utils, naersk, sops-nix, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        inherit (nixpkgs) lib;
        src = builtins.path { path = ./.; };

        # Import the secrets definition
        secretsConfig = import ./secrets.nix { inherit pkgs lib; };

        # Derivation to decrypt sops secrets
        decryptedSopsSecrets = pkgs.stdenv.mkDerivation {
          pname = "decrypted-sops-secrets";
          version = "1.0";

          buildPhase = ''
            mkdir -p $out/creds
            ${pkgs.sops}/bin/sops -d ./sops-secrets/google_accounts.json > $out/creds/google_accounts.json
          '';

          buildInputs = [ pkgs.sops ];
        };
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

          creds-test = pkgs.runCommand "creds-test"
            {
              buildInputs = [ decryptedSopsSecrets ];
            } ''
            mkdir -p $out
            cp ${decryptedSopsSecrets}/creds/google_accounts.json $out/google_accounts.json
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
