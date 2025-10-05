{ lib, pkgs, builtins, githubApiUrl, buildGraphQLQuery }:

let
  executeGraphQLQuery = { queryPayload, githubToken, name ? "github-graphql-query" }:
    "dummy derivation";
in
{
  inherit executeGraphQLQuery;
}
