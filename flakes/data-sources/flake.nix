{
  description = "Aggregates various data sources (Wikidata, Wikipedia) for the mycology workflow.";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
    # flake-utils is provided by the parent flake via 'follows'
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        inherit (pkgs) lib;

        # Reference the crq-binstore GitHub repository
        crqBinstore = pkgs.fetchTarball {
          url = "https://github.com/meta-introspector/crq-binstore/archive/main.tar.gz";
          sha256 = "sha256-04dr4qzfdf4q0b3p9klgrffmak2ra1h3dzhhsqh4qdnzdbsfim7z";
        };

        # Function to wrap a Wikipedia article (e.g., Markdown file)
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

        # Function to wrap a Wikidata NAR file (extract content)
        mkWikidataNarPackage = { name, src }:
          pkgs.runCommand name
            {
              inherit src;
              buildInputs = [ pkgs.nix ]; # nix-nar-unpack is part of nix
              passthru.articleName = name;
              passthru.source = "wikidata";
            } ''
            mkdir -p $out
            # Assuming the NAR contains a single file or a well-defined structure
            # For simplicity, we'll just copy the NAR itself for now, or unpack if needed.
            # A more sophisticated approach would use 'nix-nar-unpack' or similar.
            cp $src $out/${name}.nar
          '';
      in
      {
        # Process Wikidata NAR files
        wikidata = lib.mapAttrs'
          (name: value: {
            inherit name;
            value = mkWikidataNarPackage {
              inherit name;
              src = value;
            };
          })
          {
            Monster_Group = "${crqBinstore}/crq-binstore/09/22/crq-binstore/0wdqp67d69l33yj2rmj68x61220rqh7n-monster-group-wikidata.nar";
            Steiner_System = "${crqBinstore}/crq-binstore/09/22/crq-binstore/1bl5ylxj2rwbk26h5chaxlyk410wjl8h-steiner-system-wikidata.nar";
            Sporadic_Group = "${crqBinstore}/crq-binstore/09/22/crq-binstore/3cjka3sar7wmm1fsy04fimfp43vfl7v4-sporadic-group-wikidata.nar";
            Mathieu_Group_M12 = "${crqBinstore}/crq-binstore/09/22/crq-binstore/m3hd74h0p437b8841r4hqgd5pi02gayw-mathieu-group-m12-wikidata.nar";
          };

        # Process Wikipedia articles
        wikipedia = {
          Monster_Group = mkWikipediaArticle {
            name = "Monster_Group";
            src = pkgs.lib.cleanSourceWith {
              src = ../../09/22/tests/wikipedia_cache; # Assuming this is the relevant cache for Monster Group
              name = "wikipedia-monster-group-cache";
            };
          };
          Articles = mkWikipediaArticle {
            name = "wikipedia_articles.md";
            src = pkgs.lib.cleanSourceWith {
              src = ../../09/23/wikipedia_articles.md;
              name = "wikipedia-articles-md";
            };
          };
        };
      }
    );
}