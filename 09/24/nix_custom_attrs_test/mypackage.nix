# mypackage.nix
{ pkgs, lib, stdenv ? pkgs.stdenv, fetchurl ? pkgs.fetchurl }:

stdenv.mkDerivation rec {
  pname = "hello";
  version = "2.12";

  src = fetchurl {
    url = "mirror://gnu/hello/${pname}-${version}.tar.gz";
    sha256 = "zwSvhtwIUmjF9EcPuuSbGK+8Iht4CWqrhC2TSna60Ks="; # Corrected hash for hello-2.12
  };

  # Custom attributes
  myCustomTag = "experimental";
  myVersionOverride = "2.13-custom";
  myExtraData = ./some-local-file.txt;

  preBuild = ''
    echo "Custom tag: ${myCustomTag}"
    if [[ "$myVersionOverride" != "" ]]; then
      echo "Overriding version in Makefile"
      # sed -i "s/${version}/${myVersionOverride}/" Makefile
    fi
    echo "Extra data path: ${myExtraData}"
  '';
}
