{ lib, pkgs, builtins, ... }:

let
  rdfPrefixUrl = "http://www.w3.org/1999/02/22-rdf-syntax-ns";
  rdfPrefixSha256 = "18l625b543vqa94s3dv8pah41dy00mic2yfa0ijxvir4b0d2pmck";
  fetchedRdfPrefix = pkgs.fetchurl {
    url = rdfPrefixUrl;
    sha256 = rdfPrefixSha256;
  };
in
{
  urlString = rdfPrefixUrl;
  fetchedPath = fetchedRdfPrefix;
}