{ lib, pkgs, builtins, ... }:

let
  # A pure Nix function to construct the JSON payload for a GraphQL query.
  buildGraphQLQuery =
    { query
    , # The GraphQL query string
      variables ? { }
    , # Optional variables for the query
    }:
    builtins.toJSON {
      inherit query;
      inherit variables;
    };

in
{
  inherit buildGraphQLQuery;
}
