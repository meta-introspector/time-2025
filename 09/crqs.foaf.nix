# crqs.foaf.nix
{ pkgs
, lib
, # Import individual CRQ FOAF documents
  crq001
, crq007
, crq008
, crq009
, crq010
, crq011
, crq012
, crq013
,
}:

let
  # Aggregate all CRQ FOAF documents into a list
  allCrqs = [
    crq001
    crq007
    crq008
    crq009
    crq010
    crq011
    crq012
    crq013
  ];
in
allCrqs
