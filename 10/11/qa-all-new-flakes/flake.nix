{
  description = "QA flake to exercise all newly created Nix files and their checks.";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
    flake-utils = {
      url = "github:meta-introspector/flake-utils?ref=feature/CRQ-016-nixify";
      inputs.systems.follows = "nixpkgs/lib/systems/flakeExposed";
    };

    # New flakes created in this session
    nixDuplicationDetector = { url = "path:../nix-duplication-detector"; inputs.nixpkgs.follows = "nixpkgs"; inputs.flake-utils.follows = "flake-utils"; };
    nixNgramIndexer = { url = "path:../nix-ngram-indexer"; inputs.nixpkgs.follows = "nixpkgs"; inputs.flake-utils.follows = "flake-utils"; };
    oeisIndexer = { url = "path:../oeis-indexer"; inputs.nixpkgs.follows = "nixpkgs"; inputs.flake-utils.follows = "flake-utils"; };
    searchUtils = { url = "path:../search-utils"; inputs.nixpkgs.follows = "nixpkgs"; inputs.flake-utils.follows = "flake-utils"; };
    githubCodeSearch = { url = "path:../github-code-search"; inputs.nixpkgs.follows = "nixpkgs"; inputs.flake-utils.follows = "flake-utils"; };
    lean4Verifier = { url = "path:../lean4-verifier"; inputs.nixpkgs.follows = "nixpkgs"; inputs.flake-utils.follows = "flake-utils"; };
    ipfsStore = { url = "path:../ipfs-store"; inputs.nixpkgs.follows = "nixpkgs"; inputs.flake-utils.follows = "flake-utils"; };
    solanaIntegration = { url = "path:../solana-integration"; inputs.nixpkgs.follows = "nixpkgs"; inputs.flake-utils.follows = "flake-utils"; };
    miniZkpVerifier = { url = "path:../mini-zkp-verifier"; inputs.nixpkgs.follows = "nixpkgs"; inputs.flake-utils.follows = "flake-utils"; };
    minaZkpIntegrationTask = { url = "path:../mina-zkp-integration-task"; inputs.nixpkgs.follows = "nixpkgs"; inputs.flake-utils.follows = "flake-utils"; };
    numberSearcher = { url = "path:../number-searcher"; inputs.nixpkgs.follows = "nixpkgs"; inputs.flake-utils.follows = "flake-utils"; };
    binstorePrimeMdIndexes = { url = "path:../binstore-prime-md-indexes"; inputs.nixpkgs.follows = "nixpkgs"; inputs.flake-utils.follows = "flake-utils"; };
    fileIndexer = { url = "path:../file-indexer"; inputs.nixpkgs.follows = "nixpkgs"; inputs.flake-utils.follows = "flake-utils"; };
    fileSplitter = { url = "path:../file-splitter"; inputs.nixpkgs.follows = "nixpkgs"; inputs.flake-utils.follows = "flake-utils"; };
    keywordSearcher = { url = "path:../keyword-searcher"; inputs.nixpkgs.follows = "nixpkgs"; inputs.flake-utils.follows = "flake-utils"; };
    dataLatticeBuilder = { url = "path:../data-lattice-builder"; inputs.nixpkgs.follows = "nixpkgs"; inputs.flake-utils.follows = "flake-utils"; };
    metaIndexer = { url = "path:../meta-indexer"; inputs.nixpkgs.follows = "nixpkgs"; inputs.flake-utils.follows = "flake-utils"; };
    qaNarSimilarityPipeline = { url = "path:../qa-nar-similarity-pipeline"; inputs.nixpkgs.follows = "nixpkgs"; inputs.flake-utils.follows = "flake-utils"; };
    lmfdb2nix = { url = "path:../lmfdb2nix"; inputs.nixpkgs.follows = "nixpkgs"; inputs.flake-utils.follows = "flake-utils"; };
    narSimilaritySearch = { url = "path:../nar-similarity-search"; inputs.nixpkgs.follows = "nixpkgs"; inputs.flake-utils.follows = "flake-utils"; };
  };

  outputs = { self, nixpkgs, flake-utils,
              nixDuplicationDetector, nixNgramIndexer, oeisIndexer, searchUtils, githubCodeSearch,
              lean4Verifier, ipfsStore, solanaIntegration, miniZkpVerifier, minaZkpIntegrationTask,
              numberSearcher, binstorePrimeMdIndexes, fileIndexer, fileSplitter, keywordSearcher,
              dataLatticeBuilder, metaIndexer, qaNarSimilarityPipeline, lmfdb2nix, narSimilaritySearch
            }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        lib = nixpkgs.lib;

        # Aggregate checks from all new flakes
        allChecks = lib.recursiveMerge [
          (nixDuplicationDetector.checks.${system} or {})
          (nixNgramIndexer.checks.${system} or {})
          (oeisIndexer.checks.${system} or {})
          (searchUtils.checks.${system} or {})
          (githubCodeSearch.checks.${system} or {})
          (lean4Verifier.checks.${system} or {})
          (ipfsStore.checks.${system} or {})
          (solanaIntegration.checks.${system} or {})
          (miniZkpVerifier.checks.${system} or {})
          (qaNarSimilarityPipeline.checks.${system} or {})
        ];

      in
      {
        checks = allChecks;

        devShells.default = pkgs.mkShell {
          nativeBuildInputs = with pkgs; [
            bash
            jq
            gh
            curl
            # Tools from narSimilaritySearch (needed by qaNarSimilarityPipeline)
            narSimilaritySearch.packages.${system}.default
          ];
          shellHook = ''
            echo "Welcome to the QA devShell for all new flakes!"
            echo "Run 'nix flake check' to execute all aggregated checks."
          '';
        };
      }
    );
}