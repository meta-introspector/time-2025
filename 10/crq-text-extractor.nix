{ pkgs ? import <nixpkgs> {}, month09Flake }:

let
  crqs = month09Flake.crqs.foaf.nix {
    inherit pkgs;
    inherit (pkgs) lib;
    crq001 = month09Flake.crq-001.foaf.nix { inherit pkgs; inherit (pkgs) lib; };
    crq007 = month09Flake.crq-007.foaf.nix { inherit pkgs; inherit (pkgs) lib; };
    crq008 = month09Flake.crq-008.foaf.nix { inherit pkgs; inherit (pkgs) lib; };
    crq009 = month09Flake.crq-009.foaf.nix { inherit pkgs; inherit (pkgs) lib; };
    crq010 = month09Flake.crq-010.foaf.nix { inherit pkgs; inherit (pkgs) lib; };
    crq011 = month09Flake.crq-011.foaf.nix { inherit pkgs; inherit (pkgs) lib; };
    crq012 = month09Flake.crq-012.foaf.nix { inherit pkgs; inherit (pkgs) lib; };
    crq013 = month09Flake.crq-013.foaf.nix { inherit pkgs; inherit (pkgs) lib; };
  };

  extractText = crq: 
    let
      text = crq.title + " " + crq.problemGoal + " " + crq.proposedSolution + " " + crq.justificationImpact;
    in
    text;

  crqTexts = pkgs.lib.mapAttrs (name: extractText) (pkgs.lib.listToAttrs (map (crq: { name = crq.id; value = crq; }) crqs));

in
builtins.toJSON crqTexts