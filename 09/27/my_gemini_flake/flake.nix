{
  description = "A Nix flake that provides a development shell with the meta-introspector/gemini-cli environment.";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
    flake-utils.url = "github:meta-introspector/flake-utils?ref=feature/CRQ-016-nixify";
    gemini-cli.url = "github:meta-introspector/gemini-cli?ref=feature/test";
  };

  outputs = { self, nixpkgs, flake-utils, gemini-cli }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        devShells.default = pkgs.mkShell {
          inherit (gemini-cli.devShells.${system}.default) buildInputs;
          # You can add more buildInputs here if your specific project needs them
          # For example: pkgs.git, pkgs.vim

          # You might also want to inherit other attributes from gemini-cli's devShell
          # For example, if it sets specific environment variables.
          # preShellHook = gemini-cli.devShells.${system}.default.preShellHook;

          # Add a message to guide the user
          shellHook = ''
            echo "Welcome to the development shell for my_gemini_flake!"
            echo "The gemini-cli environment is now available."
            echo "You can now run commands like 'gemini-cli' (if it's built and available in the gemini-cli flake's devShell)."
            echo "Note: The gemini-cli flake you provided defines a devShell, but not a direct runnable app or package named 'gemini-cli'."
            echo "You might need to build or run gemini-cli from within its own source or devShell."
          '';
        };

        # We are not defining a default package or app that directly runs gemini-cli
        # as the gemini-cli flake itself doesn't expose such an app directly.
        # Instead, this flake provides the environment to work with gemini-cli.
        packages.default = pkgs.stdenv.mkDerivation {
          pname = "my-gemini-flake-env";
          version = "0.1.0";
          src = ./.;
          # No direct buildInputs needed for this package, as it's just a placeholder
          # for the environment. The actual tools come from the devShell.
          installPhase = "mkdir -p $out/bin";
        };
      }
    );
}
