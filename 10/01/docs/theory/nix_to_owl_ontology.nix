{
  nixCodeIndexerModule,
  ...
}:

let
  common = import ../../../lib/common-imports.nix {};
  lib = common.lib;
  pkgs = common.pkgs;
  builtins = common.builtins;

  # Import prefixes
  nixOntologyPrefix = (import ./nix_to_owl_ontology_declarations/prefixes/nixOntologyPrefix.nix) { inherit lib pkgs builtins; };
  owlPrefix = (import ./nix_to_owl_ontology_declarations/prefixes/owlPrefix.nix) { inherit lib pkgs builtins; };
  rdfPrefix = (import ./nix_to_owl_ontology_declarations/prefixes/rdfPrefix.nix) { inherit lib pkgs builtins; };
  rdfsPrefix = (import ./nix_to_owl_ontology_declarations/prefixes/rdfsPrefix.nix) { inherit lib pkgs builtins; };
  xsdPrefix = (import ./nix_to_owl_ontology_declarations/prefixes/xsdPrefix.nix) { inherit lib pkgs builtins; };



  nixToOwlMapper = (import ./nix_to_owl_ontology_declarations/nixToOwlMapper.nix) { inherit lib pkgs builtins nixOntologyPrefix owlPrefix rdfPrefix rdfsPrefix xsdPrefix nixCodeIndexerModule; };
