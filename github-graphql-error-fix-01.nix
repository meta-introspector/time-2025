{ lib, buildGraphQLQuery }:

let
  getRepositoryDetails = { owner, repo }:
    let
      query = "dummy query";
      variables = { inherit owner repo; };
    in
    buildGraphQLQuery { inherit query variables; };
in
{
  getRepositoryDetails = getRepositoryDetails;
}
