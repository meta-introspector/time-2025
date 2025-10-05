{ lib, pkgs, builtins, ... }:

let
  rdfsPrefixUrl = "http://www.w3.org/2000/01/rdf-schema";
  rdfsPrefixSha256 = "1mla23jzks89bq1ywlyxkzb57gp6pw4a5c20gqmfl4vw3c0kmvpc";
  fetchedRdfsPrefix = pkgs.fetchurl {
    url = rdfsPrefixUrl;
    sha256 = rdfsPrefixSha256;
  };
in
{
  urlString = rdfsPrefixUrl;
  fetchedPath = fetchedRdfsPrefix;
}