{ lib, dcterms, mkClass }:

{
  dctermsClasses = [
    (mkClass { id = "${dcterms}Document"; label = "Document"; comment = "A document, such as a CRQ."; })
  ];
}
