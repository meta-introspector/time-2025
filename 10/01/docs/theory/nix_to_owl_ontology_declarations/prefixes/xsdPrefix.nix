{ lib, pkgs, builtins, ... }:

let
  xsdPrefixUrl = "http://www.w3.org/2001/XMLSchema";
  xsdPrefixSha256 = "03g82vm6vmz0nsryzkdj75h7xvczy0l1rpyws708pqvkfyzbh63h";
  fetchedXsdPrefix = pkgs.fetchurl {
    url = xsdPrefixUrl;
    sha256 = xsdPrefixSha256;
  };
in
{
  urlString = xsdPrefixUrl;
  fetchedPath = fetchedXsdPrefix;
}