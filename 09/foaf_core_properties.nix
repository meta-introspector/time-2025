{ lib, foaf, rdfs, mkDatatypeProperty, mkObjectProperty }:

{
  foafProperties = [
    (mkDatatypeProperty { id = "${foaf}name"; label = "name"; domain = "${foaf}Agent"; range = "${rdfs}Literal"; })
    (mkObjectProperty { id = "${foaf}homepage"; label = "homepage"; domain = "${foaf}Agent"; range = "${foaf}Document"; }) # Assuming homepage points to a document
    (mkObjectProperty { id = "${foaf}maker"; label = "maker"; domain = "${foaf}Project"; range = "${foaf}Agent"; })
  ];
}
