{ lib, pkgs, builtins, ... }:

(import ../../../../github_graphql_modules/github_graphql_main.nix { inherit lib pkgs builtins; }).buildGraphQLQuery