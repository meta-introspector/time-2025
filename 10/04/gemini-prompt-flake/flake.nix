{
  description = "A flake for prime-based emoji-Brainf* interpreter and Gemini prompting.";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
    flake-utils.url = "github:meta-introspector/flake-utils?ref=feature/CRQ-016-nixify";
    gemini-cli.url = "github:meta-introspector/gemini-cli?ref=feature/CRQ-016-nixify-2025-10-06";

    # New input for the prompt string
    promptArg = {
      url = "path:./default-prompt.nix";
      flake = false; # Mark as not a flake itself
    };
  };

  outputs = { self, nixpkgs, flake-utils, gemini-cli, promptArg }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        inherit (pkgs) lib;
        # Import the prompt string from the input
        prompt = import promptArg;
      in
      {
        packages.gemini-prompt-derivation = import ./gemini-prompt-derivation.nix {
          inherit pkgs lib gemini-cli prompt; # Pass the prompt to the derivation
        };

        devShells.default = pkgs.mkShell {
          buildInputs = [
            gemini-cli.packages.${system}.default
            pkgs.nodejs_22
          ];
        };
      }
    );
}