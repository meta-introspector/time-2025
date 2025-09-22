{
  description = "Main project flake for the 2025 repository.";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
    flake-utils.url = "github:meta-introspector/flake-utils?ref=feature/CRQ-016-nixify";
    # Reference the current repository itself as a source
    # This allows other flakes within this repo to reference it
    selfRef = "path:.";
  };

  outputs = { self, nixpkgs, flake-utils, selfRef }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      {
        # Define a devShell for the main project
        devShell = pkgs.mkShell {
          buildInputs = [
            pkgs.git
            pkgs.nix
            pkgs.bash
            pkgs.coreutils
            pkgs.jq
            pkgs.gh
            pkgs.shellcheck
            pkgs.curl
            pkgs.pandoc
          ];
        };

        # You can add other packages, apps, etc. here for the main project
        # For example, to expose the LLM context builder:
        # packages.llmContextBuilder = self.nix-llm-context.packages.${system}.monsterGroupLlmContext;
      }
    );
}
