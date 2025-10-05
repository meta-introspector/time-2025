{ lib, pkgs, builtins, ... }:

let
  commonModule = import ./github_graphql_common.nix { inherit lib pkgs builtins; };
  buildQueryModule = import ./github_graphql_build_query.nix { inherit lib pkgs builtins; };

  # Extract githubApiUrl and buildGraphQLQuery from their respective modules
  githubApiUrl = commonModule.githubApiUrl;
  buildGraphQLQuery = buildQueryModule.buildGraphQLQuery;

  executeQueryModule = import ./github_graphql_execute_query.nix { inherit lib pkgs builtins githubApiUrl buildGraphQLQuery; };
  exampleQueriesModule = import ./github_graphql_example_queries.nix { inherit lib pkgs builtins buildGraphQLQuery; };

in
{
  inherit (buildQueryModule) buildGraphQLQuery;
  inherit (executeQueryModule) executeGraphQLQuery;
  inherit (exampleQueriesModule) exampleQueries;
}
