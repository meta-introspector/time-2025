{ lib, dcterms, rdfs, foaf, mkDatatypeProperty, mkObjectProperty }:

{
  dctermsProperties = [
    (mkDatatypeProperty { id = "${dcterms}title"; label = "title"; domain = "${dcterms}Document"; range = "${rdfs}Literal"; })
    (mkDatatypeProperty { id = "${dcterms}description"; label = "description"; domain = "${dcterms}Document"; range = "${rdfs}Literal"; })
    (mkDatatypeProperty { id = "${dcterms}identifier"; label = "identifier"; domain = "${dcterms}Document"; range = "${rdfs}Literal"; })
    (mkDatatypeProperty { id = "${dcterms}created"; label = "created"; domain = "${dcterms}Document"; range = "${rdfs}Literal"; }) # Could be xsd:dateTime
    (mkObjectProperty { id = "${dcterms}creator"; label = "creator"; domain = "${dcterms}Document"; range = "${foaf}Agent"; })
  ];
}
