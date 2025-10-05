{ lib, buildGraphQLQuery }:

let
  getRepositoryDetails = { owner, repo }:
    let
      query = "simple query";
      variables = { inherit owner repo; };
    in
    buildGraphQLQuery { inherit query variables; };
in
{
  getRepositoryDetails = getRepositoryDetails;
}