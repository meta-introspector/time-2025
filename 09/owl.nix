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

in {
  fetchUrlImpure = fetchUrlImpure;
  "@context" = {
    "owl" = owl;
    "rdf" = rdf;
    "rdfs" = rdfs;
    "foaf" = foaf;
    "dcterms" = "http://purl.org/dc/terms/";
    "schema" = schema;
    "github" = "https://github.com/ontology/";
  };

  "@graph" = [
    # Classes
    (mkClass { id = "${foaf}Agent"; label = "Agent"; comment = "An agent (e.g. person, group, software or machine)."; })
    (mkClass { id = "${foaf}Project"; label = "Project"; comment = "A project (a collective thing which may be run by one or more agents)."; })
    (mkClass { id = "${schema}Solution"; label = "Solution"; comment = "A proposed solution to a problem."; })
    (mkClass { id = "${schema}Impact"; label = "Impact"; comment = "The impact or justification of a solution."; })
    (mkClass { id = "${dcterms}Document"; label = "Document"; comment = "A document, such as a CRQ."; })

    # GitHub Classes
    (mkClass { id = "${github}Repository"; label = "Repository"; comment = "A GitHub repository."; subClassOf = "${foaf}Project"; })
    (mkClass { id = "${github}User"; label = "User"; comment = "A GitHub user."; subClassOf = "${foaf}Agent"; })
    (mkClass { id = "${github}Commit"; label = "Commit"; comment = "A Git commit."; })
    (mkClass { id = "${github}Issue"; label = "Issue"; comment = "A GitHub issue."; })
    (mkClass { id = "${github}PullRequest"; label = "PullRequest"; comment = "A GitHub pull request."; })
    (mkClass { id = "${github}Event"; label = "Event"; comment = "A GitHub event."; })

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

    # GitHub Properties
    (mkObjectProperty { id = "${github}hasOwner"; label = "has owner"; domain = "${github}Repository"; range = "${github}User"; })
    (mkObjectProperty { id = "${github}hasContributor"; label = "has contributor"; domain = "${github}Repository"; range = "${github}User"; })
    (mkObjectProperty { id = "${github}hasCommit"; label = "has commit"; domain = "${github}Repository"; range = "${github}Commit"; })
    (mkObjectProperty { id = "${github}hasIssue"; label = "has issue"; domain = "${github}Repository"; range = "${github}Issue"; })
    (mkObjectProperty { id = "${github}hasPullRequest"; label = "has pull request"; domain = "${github}Repository"; range = "${github}PullRequest"; })
    (mkObjectProperty { id = "${github}hasEvent"; label = "has event"; domain = "${github}Repository"; range = "${github}Event"; })
    (mkDatatypeProperty { id = "${github}commitMessage"; label = "commit message"; domain = "${github}Commit"; range = "${rdfs}Literal"; })
    (mkObjectProperty { id = "${github}commitAuthor"; label = "commit author"; domain = "${github}Commit"; range = "${github}User"; })
    (mkDatatypeProperty { id = "${github}issueTitle"; label = "issue title"; domain = "${github}Issue"; range = "${rdfs}Literal"; })
    (mkDatatypeProperty { id = "${github}issueBody"; label = "issue body"; domain = "${github}Issue"; range = "${rdfs}Literal"; })
    (mkDatatypeProperty { id = "${github}issueState"; label = "issue state"; domain = "${github}Issue"; range = "${rdfs}Literal"; })
    (mkDatatypeProperty { id = "${github}eventTimestamp"; label = "event timestamp"; domain = "${github}Event"; range = "${rdfs}Literal"; })
  ]
}
