{ buildGraphQLQuery, ... }:

let
  # Conceptual examples of GitHub GraphQL queries
  exampleQueries = {
    # Query to get repository details
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
      }
      let
        builtQuery = buildGraphQLQuery { inherit query variables; };
      in
      builtQuery;

    # Query to list issues for a repository
    listRepositoryIssues = { owner, repo, first ? 10 }:
      let
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
        builtQuery = buildGraphQLQuery { inherit query variables; };
      in
      builtQuery;
  };
in
exampleQueries
