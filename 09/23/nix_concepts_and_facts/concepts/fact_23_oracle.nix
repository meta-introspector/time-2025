{ pkgs ? import <nixpkgs> {} }:

let
  repo = pkgs.fetchGit {
    url = "file:///data/data/com.termux.nix/files/home/pick-up-nix2"; # Reference the local repository
    rev = "af69f9671f9590b04c3254884e523e336a815d2d";
  };
in

pkgs.runCommand "fact-23-oracle" { }''
  cp ${repo}/source/github/meta-introspector/streamofrandom/2025/09/23/nix_concepts_and_facts/facts/fact_about_23.txt $out/fact
''
