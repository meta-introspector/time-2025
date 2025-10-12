# 10/12/default.nix
{ pkgs ? import <nixpkgs> { } }:

{
  myVariable = "hello from 10/12/default.nix";
  anotherVariable = 123;
  aList = [ 1 2 3 ];
  zos = [ 0 1 2 3 5 7 11 13 17 19 ];
}
