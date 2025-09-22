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
        monsterGroupFiles = pkgs.lib.cleanSourceWith {
          src = ./.;
          filter = name: type:
            let baseName = baseNameOf (toString name); in
            pkgs.lib.any (s: pkgs.lib.hasInfix s baseName) [
              "monster_group"
              "monster_godel_trace"
              "monstrous_moonshine"
              "crq_introspection_monster_group"
            ];
        };
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

        # Define a default package for the main project
        packages.default = pkgs.writeShellScriptBin "hello-nix" ''
          echo "Hello from Nix!"
        '';

        # Package for Monster Group Wikidata
        packages.monsterGroupWikidata = pkgs.runCommand "monster-group-wikidata" {
          inherit monsterGroupFiles;
          buildInputs = [ pkgs.coreutils ]; # For cp
        } ''
          mkdir -p $out
          cp -r $monsterGroupFiles/* $out/
        '';

        # You can add other packages, apps, etc. here for the main project
        # For example, to expose the LLM context builder:
        # packages.llmContextBuilder = self.nix-llm-context.packages.${system}.monsterGroupLlmContext;
      }
    );
}
