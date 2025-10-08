{ lib, buildGraphQLQuery }:

{
  listRepositoryIssues = { owner, repo, first ? 10 }:
    (let
      query = ''
        query ($owner: String!, $repo: String!, $first: Int!) {
          repository(owner: $owner, name: $repo) {
            issues(first: $first) {
              nodes {
                title
                url
                state
              }
            }
          }
        }
      '';
      variables = { inherit owner repo first; };
    in
    buildGraphQLQuery { inherit query variables; });
}
