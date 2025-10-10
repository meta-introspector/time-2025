{ lib, pkgs, firstReflection, allFlakeNixFiles, allGitmodulesFiles }:

let
  extractedInfo = {
    flakeCommands = lib.flatten (lib.map (flakePath: (firstReflection.identityPrincipleSpec.rawCommandExtraction.extractFlakeCommands flakePath).commands) allFlakeNixFiles);
    flakeUrls = lib.flatten (lib.map (flakePath: (firstReflection.identityPrincipleSpec.rawCommandExtraction.extractFlakeCommands flakePath).urls) allFlakeNixFiles);
    flakeSystems = lib.flatten (lib.map (flakePath: (firstReflection.identityPrincipleSpec.rawCommandExtraction.extractFlakeCommands flakePath).systems) allFlakeNixFiles);
    submoduleUrls = lib.flatten (lib.map (gitmodulesPath: firstReflection.identityPrincipleSpec.rawCommandExtraction.extractSubmoduleUrls gitmodulesPath) allGitmodulesFiles);
    submoduleBranches = lib.flatten (lib.map (gitmodulesPath: firstReflection.identityPrincipleSpec.rawCommandExtraction.extractSubmoduleBranches gitmodulesPath) allGitmodulesFiles);
  };
in
extractedInfo
