# owl.nix
{ pkgs, lib, builtins, ... }:

let
  # OWL namespace
  owl = "http://www.w3.org/2002/07/owl#";
  rdf = "http://www.w3.org/1999/02/22-rdf-syntax-ns#";
  rdfs = "http://www.w3.org/2000/01/rdf-schema#";
  foaf = "http://xmlns.com/foaf/0.1/";
  dcterms = "http://purl.org/dc/terms/";
  schema = "http://schema.org/";
  github = "https://github.com/ontology/"; # Keep github namespace here for now

  fetchUrlImpure = (import ../fetch-url-impure.nix { inherit builtins; }).fetchUrlImpure;

  # Helper function to create an OWL Class
  mkClass = { id, label, comment ? null, subClassOf ? null } :
    {
      "@id" = id;
      "@type" = "${owl}Class";
      "${rdfs}label" = label;
    } // (lib.optionalAttrs (comment != null) { "${rdfs}comment" = comment; })
      // (lib.optionalAttrs (subClassOf != null) { "${rdfs}subClassOf" = subClassOf; });

  # Helper function to create an OWL ObjectProperty
  mkObjectProperty = { id, label, comment ? null, domain ? null, range ? null } :
    {
      "@id" = id;
      "@type" = "${owl}ObjectProperty";
      "${rdfs}label" = label;
    } // (lib.optionalAttrs (comment != null) { "${rdfs}comment" = comment; })
      // (lib.optionalAttrs (domain != null) { "${rdfs}domain" = domain; })
      // (lib.optionalAttrs (range != null) { "${rdfs}range" = range; });

  # Helper function to create an OWL DatatypeProperty
  mkDatatypeProperty = { id, label, comment ? null, domain ? null, range ? null } :
    {
      "@id" = id;
      "@type" = "${owl}DatatypeProperty";
      "${rdfs}label" = label;
    } // (lib.optionalAttrs (comment != null) { "${rdfs}comment" = comment; })
      // (lib.optionalAttrs (domain != null) { "${rdfs}domain" = domain; })
      // (lib.optionalAttrs (range != null) { "${rdfs}range" = range; });

  # Import modularized ontology parts
  foafCoreClasses = import ./foaf_core_classes.nix { inherit lib foaf mkClass; };
  schemaCoreClasses = import ./schema_core_classes.nix { inherit lib schema mkClass; };
  dctermsCoreClasses = import ./dcterms_core_classes.nix { inherit lib dcterms mkClass; };
  githubOwlModule = import ./github.owl.nix { inherit pkgs lib builtins mkClass mkObjectProperty mkDatatypeProperty github foaf rdfs; };

  foafCoreProperties = import ./foaf_core_properties.nix { inherit lib foaf rdfs mkDatatypeProperty mkObjectProperty; };
  dctermsCoreProperties = import ./dcterms_core_properties.nix { inherit lib dcterms rdfs foaf mkDatatypeProperty mkObjectProperty; };
  schemaCoreProperties = import ./schema_core_properties.nix { inherit lib schema dcterms mkObjectProperty; };

in {
  fetchUrlImpure = fetchUrlImpure;
  "@context" = {
    "owl" = owl;
    "rdf" = rdf;
    "rdfs" = rdfs;
    "foaf" = foaf;
    "dcterms" = "http://purl.org/dc/terms/";
    "schema" = schema;
    "github" = github;
  };

  "@graph" = 
    foafCoreClasses.foafClasses
    ++ schemaCoreClasses.schemaClasses
    ++ dctermsCoreClasses.dctermsClasses
    ++ githubOwlModule.githubClasses
    ++ foafCoreProperties.foafProperties
    ++ dctermsCoreProperties.dctermsProperties
    ++ schemaCoreProperties.schemaProperties
    ++ githubOwlModule.githubProperties;
};