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
            passthru.articleName = article;
            passthru.wikipedia = article;
          } ''
            mkdir -p $out
            cp $src $out/${article}
          '';

        # Wikidata Packages
        wikidataPackages = pkgs.lib.mapAttrs (
          name: type:
            let
              articleName = pkgs.lib.removeSuffix ".html" name;
              packageName = pkgs.lib.toCamel name;
            in
            mkWikidataPackage {
              name = "${articleName}-wikidata";
              article = name;
            }
        ) (builtins.readDir ./wikipedia_cache);

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

        packages = wikidataPackages // {
          default = pkgs.writeShellScriptBin "hello-nix" ''
            echo "Hello from Nix!"
          '';
        };

        # You can add other packages, apps, etc. here for the main project
        # For example, to expose the LLM context builder:
        # packages.llmContextBuilder = self.nix-llm-context.packages.${system}.monsterGroupLlmContext;

        # Temporarily commented out due to missing unpack-zos-sequence.sh in dependency
        # packages.default = day_23_concepts.packages.${system}.default; # Expose ai-context-23 as default
        # inherit (day_23_concepts.packages.${system}) number-23 is-prime-23 fact-23-oracle; # Expose individual concepts
      }
    );
}
