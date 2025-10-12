{ pkgs ? import <nixpkgs> { } }:

pkgs.stdenv.mkDerivation {
  pname = "rnix-flake-ast-nar";
  version = "1.0";

  src = ./../../10/12/binstore/rnix-flake-ast.nar;

  installPhase = ''
    mkdir -p $out
    cp $src $out/rnix-flake-ast.nar
  '';
}
