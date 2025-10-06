{
  nixCodeIndexerModule,
  nixOntologyRepo,
  ...
}:

let
  common = import ../../../lib/common-imports.nix {};
  inherit (common) lib;
  inherit (common) pkgs;
  inherit (common) builtins;

  # Import prefixes
  nixOntologyPrefix = (import ./nix_to_owl_ontology_declarations/prefixes/nixOntologyPrefix.nix) { inherit lib pkgs builtins nixOntologyRepo; };
  owlPrefix = (import ./nix_to_owl_ontology_declarations/prefixes/owlPrefix.nix) { inherit lib pkgs builtins; };
  rdfPrefix = (import ./nix_to_owl_ontology_declarations/prefixes/rdfPrefix.nix) { inherit lib pkgs builtins; };
  rdfsPrefix = (import ./nix_to_owl_ontology_declarations/prefixes/rdfsPrefix.nix) { inherit lib pkgs builtins; };
  xsdPrefix = (import ./nix_to_owl_ontology_declarations/prefixes/xsdPrefix.nix) { inherit lib pkgs builtins; };



  nixToOwlMapper = nixFileIndex: (import ./nix_to_owl_ontology_declarations/nixToOwlMapper.nix) {
    inherit lib pkgs builtins nixCodeIndexerModule nixOntologyPrefix nixFileIndex;
    inherit owlPrefix; # Pass the attribute set
    inherit rdfPrefix; # Pass the attribute set
    inherit rdfsPrefix; # Pass the attribute set
    inherit xsdPrefix; # Pass the attribute set
  };
in
{
  inherit nixToOwlMapper;
}
