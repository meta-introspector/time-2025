{
  description = "StreamOfRandom CLI with NAR output capabilities";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
    flake-utils.url = "github:meta-introspector/flake-utils?ref=feature/CRQ-016-nixify";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        # Point to the standalone Rust project
        streamofrandomCliStandalone = ./streamofrandom_cli_standalone;

        # Build the CLI package
        cliPackage = pkgs.rustPlatform.buildRustPackage {
          pname = "streamofrandom_cli";
          version = "0.1.0";
          src = streamofrandomCliStandalone;

          cargoSha256 = "0000000000000000000000000000000000000000000000000000"; # Will need to be updated

          buildInputs = with pkgs; [
            openssl
            nix
          ];

          nativeBuildInputs = with pkgs; [
            pkg-config
          ];
        };

      in
      {
        packages.default = cliPackage;

        devShells.default = pkgs.mkShell {
          nativeBuildInputs = with pkgs; [
            bash
            nix
            rustc
            cargo
            pkg-config
            openssl
          ];

          shellHook = ''
            echo "Welcome to the devShell for response-007-cli-nar-output."
            echo "The 'streamofrandom_cli' is available for development."
            echo "Try: cargo run -- today"
            echo "Try: cargo run -- packet-craft"
            echo "Try: GITHUB_TOKEN=... cargo run -- github-search nixos"
          '';
        };
      });
}
