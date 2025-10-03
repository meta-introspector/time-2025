{ pkgs ? import <nixpkgs> {} }:

let
  crqs = import ../09/crqs.foaf.nix {
    inherit pkgs;
    lib = pkgs.lib;
    crq001 = import ../09/crq-001.foaf.nix { inherit pkgs; lib = pkgs.lib; };
    crq007 = import ../09/crq-007.foaf.nix { inherit pkgs; lib = pkgs.lib; };
    crq008 = import ../09/crq-008.foaf.nix { inherit pkgs; lib = pkgs.lib; };
    crq009 = import ../09/crq-009.foaf.nix { inherit pkgs; lib = pkgs.lib; };
    crq010 = import ../09/crq-010.foaf.nix { inherit pkgs; lib = pkgs.lib; };
    crq011 = import ../09/crq-011.foaf.nix { inherit pkgs; lib = pkgs.lib; };
    crq012 = import ../09/crq-012.foaf.nix { inherit pkgs; lib = pkgs.lib; };
    crq013 = import ../09/crq-013.foaf.nix { inherit pkgs; lib = pkgs.lib; };
  };

  extractText = crq: 
    let
      text = crq.title + " " + crq.problemGoal + " " + crq.proposedSolution + " " + crq.justificationImpact;
    in
    text;

  crqTexts = pkgs.lib.mapAttrs (name: value: extractText value) (pkgs.lib.listToAttrs (map (crq: { name = crq.id; value = crq; }) crqs));

in
builtins.toJSON crqTexts