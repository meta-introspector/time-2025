{ lib, builtins, nixOntologyRepo, pkgs, self, nixpkgs, nixFileIndexDerivation, ... }:

let
  urlReader = import (self + "/lib/url_url_reader.nix") { inherit lib pkgs builtins; };
  urlExtractor = import (self + "/lib/url_extractor.nix") { inherit lib pkgs builtins; };

  fetchedWebsite = urlReader.fetchImpureUrl {
    url = "https://example.com"; # Replace with the actual spec website URL
    name = "example-spec-website";
  };

  nixCodeIndexerModule = import (self + "/10/01/docs/theory/nix_code_indexer.nix") { inherit lib pkgs builtins; };

  nixFileIndex = nixCodeIndexerModule.indexNixFiles {
    path = self;
    name = "nix-files-index";
  };

  nixToOwlOntologyModule = import (self + "/10/01/docs/theory/nix_to_owl_ontology.nix") {
    inherit lib pkgs builtins nixOntologyRepo nixpkgs nixCodeIndexerModule;
  };

  # Call nixToOwlMapper with the provided nixFileIndexDerivation
  nixToOwlOntology = pkgs.writeText "nix-owl-ontology.owl" (builtins.readFile "${nixToOwlOntologyModule.nixToOwlMapper nixFileIndexDerivation}/nix-ontology.ttl");

  # Extract URLs from the nixOntologyRepo
  extractedUrls = urlExtractor.extractUrls {
    path = nixOntologyRepo;
    name = "ontology-urls";
  };
in
{
  inherit fetchedWebsite;
  inherit nixToOwlOntology;
  inherit extractedUrls;
  inherit nixToOwlOntologyModule;
}