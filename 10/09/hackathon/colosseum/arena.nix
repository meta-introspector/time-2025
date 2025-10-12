{ pkgs ? import <nixpkgs> { } }:

pkgs.stdenv.mkDerivation {
  pname = "colosseum-arena-page";
  version = "latest";
  dontUnpack = true;
  buildInputs = [ pkgs.pandoc ]; # Add pandoc here
  src = pkgs.fetchurl {
    url = "https://arena.colosseum.org/";
    sha256 = "PosgUh006PGADDCG10LXvQ2EzJQ1kzPkFJtcDVvbEx4=";
  };
  installPhase = ''
    mkdir -p $out
    # Convert the fetched HTML to Pandoc's JSON internal representation
    pandoc -s -t json -o $out/output.json $src
  '';
}
