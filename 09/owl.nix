# owl.nix
{ pkgs, lib, ... }:

let
  # OWL namespace
  owl = "http://www.w3.org/2002/07/owl#";
  rdf = "http://www.w3.org/1999/02/22-rdf-syntax-ns#";
  rdfs = "http://www.w3.org/2000/01/rdf-schema#";
  foaf = "http://xmlns.com/foaf/0.1/";
  dcterms = "http://purl.org/dc/terms/";
  schema = "http://schema.org/";

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

in {
  "@context" = {
    "owl" = owl;
    "rdf" = rdf;
    "rdfs" = rdfs;
    "foaf" = foaf;
    "dcterms" = dcterms;
    "schema" = schema;
  };

  "@graph" = [
    # Classes
    (mkClass { id = "${foaf}Agent"; label = "Agent"; comment = "An agent (e.g. person, group, software or machine)."; })
    (mkClass { id = "${foaf}Project"; label = "Project"; comment = "A project (a collective thing which may be run by one or more agents)."; })
    (mkClass { id = "${schema}Solution"; label = "Solution"; comment = "A proposed solution to a problem."; })
    (mkClass { id = "${schema}Impact"; label = "Impact"; comment = "The impact or justification of a solution."; })
    (mkClass { id = "${dcterms}Document"; label = "Document"; comment = "A document, such as a CRQ."; })

    # Properties
    (mkDatatypeProperty { id = "${foaf}name"; label = "name"; domain = "${foaf}Agent"; range = "${rdfs}Literal"; })
    (mkObjectProperty { id = "${foaf}homepage"; label = "homepage"; domain = "${foaf}Agent"; range = "${foaf}Document"; }) # Assuming homepage points to a document
    (mkDatatypeProperty { id = "${dcterms}title"; label = "title"; domain = "${dcterms}Document"; range = "${rdfs}Literal"; })
    (mkDatatypeProperty { id = "${dcterms}description"; label = "description"; domain = "${dcterms}Document"; range = "${rdfs}Literal"; })
    (mkObjectProperty { id = "${foaf}maker"; label = "maker"; domain = "${foaf}Project"; range = "${foaf}Agent"; })
    (mkDatatypeProperty { id = "${dcterms}identifier"; label = "identifier"; domain = "${dcterms}Document"; range = "${rdfs}Literal"; })
    (mkDatatypeProperty { id = "${dcterms}created"; label = "created"; domain = "${dcterms}Document"; range = "${rdfs}Literal"; }) # Could be xsd:dateTime
    (mkObjectProperty { id = "${dcterms}creator"; label = "creator"; domain = "${dcterms}Document"; range = "${foaf}Agent"; })

    # CRQ specific properties
    (mkObjectProperty { id = "${schema}solution"; label = "solution"; domain = "${dcterms}Document"; range = "${schema}Solution"; })
    (mkObjectProperty { id = "${schema}impact"; label = "impact"; domain = "${dcterms}Document"; range = "${schema}Impact"; })
  ];
}
