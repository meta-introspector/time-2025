{ pkgs ? import <nixpkgs> {}, self, month09Flake }:

let
  crqBigrams = import ./crq-bigram-generator.nix { inherit pkgs self month09Flake; };

  jaccardSimilarity = bigrams1: bigrams2: 
    let
      uniqueBigrams1 = pkgs.lib.unique bigrams1;
      uniqueBigrams2 = pkgs.lib.unique bigrams2;

      intersection = pkgs.lib.intersectLists uniqueBigrams1 uniqueBigrams2;
      union = pkgs.lib.unique (uniqueBigrams1 ++ uniqueBigrams2);

      intersectionSize = builtins.length intersection;
      unionSize = builtins.length union;
    in
    if unionSize == 0 then 0.0 else (intersectionSize / unionSize);

  crqIds = builtins.attrNames crqBigrams;

  similarityMatrix = pkgs.lib.listToAttrs (map (id1: {
    name = id1;
    value = pkgs.lib.listToAttrs (map (id2: {
      name = id2;
      value = jaccardSimilarity crqBigrams.${id1} crqBigrams.${id2};
    }) crqIds);
  }) crqIds);

in
{
  bigramIndex = crqBigrams;
  inherit similarityMatrix;
}
