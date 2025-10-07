{ lib, buildGraphQLQuery }:

let
  # Define the function directly in the let block
  getRepositoryDetailsFunction = { owner, repo }:
    let
      query = "dummy query";
      variables = { inherit owner repo; };
    in
    buildGraphQLQuery { inherit query variables; };
in
# Return an attribute set with the function
{
  getRepositoryDetails = getRepositoryDetailsFunction;
}
