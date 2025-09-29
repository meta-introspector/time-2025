{
  description = "A Nix flake that provides a development shell with access to ~/.gemini and the gemini_api_consumer.";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
    flake-utils.url = "github:meta-introspector/flake-utils?ref=feature/CRQ-016-nixify";
    gemini-api-consumer-flake.url = "path:../gemini_api_consumer_flake"; # Relative path to the consumer flake
  };

  outputs = { self, nixpkgs, flake-utils, gemini-api-consumer-flake }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        geminiConsumerApp = gemini-api-consumer-flake.apps.${system}.default;
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = [
            # Add any other tools needed in the shell here
            pkgs.bash
          ];

          # Make the gemini-api-consumer app available in the shell
          # This will add the 'gemini-api-consumer-app' executable to the PATH
          # which is the shell script that runs gemini_consumer.py
          packages = [
            geminiConsumerApp
          ];

          shellHook = ''
            echo "Welcome to the development shell with ~/.gemini access!"
            echo "The 'gemini-api-consumer-app' is available."

            # Create a symlink to the user's actual ~/.gemini directory
            # This makes ~/.gemini accessible within the Nix shell environment.
            # We use a temporary directory to avoid polluting the user's home.
            export GEMINI_HOME_DIR="$HOME/.gemini"
            mkdir -p "$GEMINI_HOME_DIR" # Ensure the actual directory exists

            # Create a temporary directory for the symlink within the shell
            # This is a common pattern to make host files accessible in Nix shells
            # without directly modifying the Nix store.
            export XDG_CONFIG_HOME=$(mktemp -d)
            ln -s "$GEMINI_HOME_DIR" "$XDG_CONFIG_HOME/.gemini"

            echo "Symlink created: $XDG_CONFIG_HOME/.gemini -> $GEMINI_HOME_DIR"
            echo "You can now access your Gemini configuration via ~/.gemini within this shell."
            echo "Remember to set GEMINI_API_KEY if you haven't already: export GEMINI_API_KEY='YOUR_API_KEY'"
          '';
        };
      }
    );
}
