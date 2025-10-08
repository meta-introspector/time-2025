{ lib, schema, dcterms, mkObjectProperty }:

{
  schemaProperties = [
    (mkObjectProperty { id = "${schema}solution"; label = "solution"; domain = "${dcterms}Document"; range = "${schema}Solution"; })
    (mkObjectProperty { id = "${schema}impact"; label = "impact"; domain = "${dcterms}Document"; range = "${schema}Impact"; })
  ];
}
