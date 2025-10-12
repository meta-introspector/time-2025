{ pkgs ? import <nixpkgs> { }, lib ? pkgs.lib, builtins ? builtins }: { inherit pkgs lib builtins; }
