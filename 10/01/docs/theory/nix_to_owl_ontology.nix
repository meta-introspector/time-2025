{
  nixCodeIndexerModule,
  nixOntologyRepo,
  ...
}:

let
  common = import ../../../lib/common-imports.nix {};
  lib = common.lib;
  pkgs = common.pkgs;
  builtins = common.builtins;

  # Import prefixes
  nixOntologyPrefix = (import ./nix_to_owl_ontology_declarations/prefixes/nixOntologyPrefix.nix) { inherit lib pkgs builtins nixOntologyRepo; };
  owlPrefix = (import ./nix_to_owl_ontology_declarations/prefixes/owlPrefix.nix) { inherit lib pkgs builtins; };
  rdfPrefix = (import ./nix_to_owl_ontology_declarations/prefixes/rdfPrefix.nix) { inherit lib pkgs builtins; };
  rdfsPrefix = (import ./nix_to_owl_ontology_declarations/prefixes/rdfsPrefix.nix) { inherit lib pkgs builtins; };
  xsdPrefix = (import ./nix_to_owl_ontology_declarations/prefixes/xsdPrefix.nix) { inherit lib pkgs builtins; };



  nixToOwlMapper = nixFileIndex: (import ./nix_to_owl_ontology_declarations/nixToOwlMapper.nix) {
    inherit lib pkgs builtins nixCodeIndexerModule nixOntologyPrefix nixFileIndex;
    owlPrefix = owlPrefix; # Pass the attribute set
    rdfPrefix = rdfPrefix; # Pass the attribute set
    rdfsPrefix = rdfsPrefix; # Pass the attribute set
    xsdPrefix = xsdPrefix; # Pass the attribute set
  };
in
{
  inherit nixToOwlMapper;
}
