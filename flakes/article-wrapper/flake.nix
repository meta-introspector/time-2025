{
  description = "Nix flake to wrap and process articles from various data sources (Wikidata, Wikipedia).";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
    flake-utils.url = "github:meta-introspector/flake-utils?ref=feature/CRQ-016-nixify";
    dataSources = {
      url = "github:meta-introspector/time-2025?ref=feature/lattice-30030-homedir&dir=flakes/data-sources"; # Point to the data-sources flake in the current repo
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
      };
    };
  };

  outputs = { self, nixpkgs, flake-utils, dataSources }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        inherit (pkgs) lib;

        # Function to wrap a Wikipedia article
        mkWikipediaArticle = { name, src }:
          pkgs.runCommand name
            {
              inherit src;
              buildInputs = [ pkgs.coreutils ];
              passthru.articleName = name;
              passthru.source = "wikipedia";
            } ''
            mkdir -p $out
            cp $src $out/${name}
          '';

        # Function to wrap a Wikidata NAR file
        mkWikidataNar = { name, src }:
          pkgs.runCommand name
            {
              inherit src;
              buildInputs = [ pkgs.coreutils ];
              passthru.articleName = name;
              passthru.source = "wikidata";
            } ''
            mkdir -p $out
            cp $src $out/${name}.nar
          '';

        # Process Wikipedia articles
        wikipediaArticles = lib.mapAttrs'
          (name: value: {
            name = lib.removeSuffix ".md" name;
            value = mkWikipediaArticle {
              name = lib.removeSuffix ".md" name;
              src = value;
            };
          })
          (builtins.readDir dataSources.wikipedia.Articles); # Assuming Articles is a directory of .md files

        # Process Wikidata NAR files
        wikidataNars = lib.mapAttrs'
          (name: value: {
            inherit name;
            value = mkWikidataNar {
              inherit name;
              src = value;
            };
          })
          dataSources.wikidata; # Assuming wikidata is an attrset of NAR paths

      in
      {
        packages.default = {
          inherit wikipediaArticles wikidataNars;
        };
      }
    );
}