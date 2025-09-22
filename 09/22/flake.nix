{
  description = "Main project flake for the 2025 repository.";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
    flake-utils.url = "github:meta-introspector/flake-utils?ref=feature/CRQ-016-nixify";
    # Reference parent repositories for flake integration
    nix2 = {
      url = "git+https://github.com/meta-introspector/pick-up-nix?ref=feature/808017424794512875886459904961710757005754368000000000";
    };
    streamofrandom = {
      url = "git+https://github.com/meta-introspector/streamofrandom?ref=feature/808017424794512875886459904961710757005754368000000000";
    };
    # time2025 = "git+https://github.com/meta-introspector/time-2025?ref=feature/808017424794512875886459904961710757005754368000000000";
  };

  outputs = { self, nixpkgs, flake-utils, nix2, streamofrandom }:
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
