{ pkgs ? import <nixpkgs> { } }:
pkgs.stdenv.mkDerivation {
  pname = "dummy-nix-file";
  version = "0.1";
  buildCommand = "echo 'hello from dummy' > $out/hello.txt";
}
