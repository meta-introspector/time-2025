{ lib, pkgs, builtins, ... }:

let
  owlPrefixUrl = "http://www.w3.org/2002/07/owl";
  owlPrefixSha256 = "1i9g4qcisizmjgym8c4kzvv7whwi7xa9hhz9zidk3ls0g3ds33vi";
  fetchedOwlPrefix = pkgs.fetchurl {
    url = owlPrefixUrl;
    sha256 = owlPrefixSha256;
  };
in
{
  urlString = owlPrefixUrl;
  fetchedPath = fetchedOwlPrefix;
}