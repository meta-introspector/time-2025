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

        mkWikidataPackage = { name, article }:
          pkgs.runCommand name {
            src = ./wikipedia_cache/${article};
            buildInputs = [ pkgs.coreutils ];
          } ''
            mkdir -p $out
            cp $src $out/${article}
          '';

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

        # Wikidata Packages
        packages.monsterGroupWikidata = mkWikidataPackage {
          name = "monster-group-wikidata";
          article = "Monster_group.html";
        };

        packages.steinerSystemWikidata = mkWikidataPackage {
          name = "steiner-system-wikidata";
          article = "Steiner_system.html";
        };

        packages.mathieuGroupM12Wikidata = mkWikidataPackage {
          name = "mathieu-group-m12-wikidata";
          article = "Mathieu_group_M12.html";
        };

        packages.sporadicGroupWikidata = mkWikidataPackage {
          name = "sporadic-group-wikidata";
          article = "Sporadic_group.html";
        };

        packages.ontologyWikidata = mkWikidataPackage {
          name = "ontology-wikidata";
          article = "Ontology.html";
        };

        # You can add other packages, apps, etc. here for the main project
        # For example, to expose the LLM context builder:
        # packages.llmContextBuilder = self.nix-llm-context.packages.${system}.monsterGroupLlmContext;
      }
    );
}
