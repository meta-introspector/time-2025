{ pkgs ? import <nixpkgs> { }
, ...
}:

pkgs.runCommand "hello-world" { }
  ''
    mkdir -p $out
    echo "Hello, Nix!" > $out/hello.txt
  ''
