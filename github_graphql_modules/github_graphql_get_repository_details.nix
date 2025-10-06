{ lib, buildGraphQLQuery }:

{
  getRepositoryDetails = { owner, repo }:
    let
      query = ''
        query ($owner: String!, $repo: String!) {
          repository(owner: $owner, name: $repo) {
            name
            description
            stargazerCount
            forkCount
            url
          }
        }
      '';
      variables = { inherit owner repo; };
    in buildGraphQLQuery { inherit query variables; };
}