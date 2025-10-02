{
  ...}:

let
  common = import ../../../lib/common-imports.nix {};
  lib = common.lib;
  pkgs = common.pkgs;
  builtins = common.builtins;

  githubApiUrl = "https://api.github.com/graphql";

  # A pure Nix function to construct the JSON payload for a GraphQL query.
  buildGraphQLQuery = { 
    query,    # The GraphQL query string
    variables ? {}, # Optional variables for the query
  }:
  builtins.toJSON {
    inherit query;
    inherit variables;
  };

  # An impure Nix derivation to execute a GraphQL query against the GitHub API.
  # This requires a GitHub Personal Access Token (PAT).
  executeGraphQLQuery = { 
    queryPayload, # The JSON payload constructed by buildGraphQLQuery
    githubToken,  # GitHub Personal Access Token (PAT)
    name ? "github-graphql-query",
  }:
    pkgs.runCommand name {
      inherit queryPayload githubToken;
      __impure = true; # Network request to GitHub API is impure
      nativeBuildInputs = [ pkgs.curl ]; # Use curl to make the HTTP request
    }
    ''
      echo "Executing GitHub GraphQL query..." >&2
      mkdir -p $out

      # Write the query payload to a temporary file
      echo "$queryPayload" > query.json

      # Execute the query using curl
      curl -s -X POST \
        -H "Authorization: Bearer $githubToken" \
        -H "Content-Type: application/json" \
        --data @query.json \
        "${githubApiUrl}" > $out/response.json

      # Check for errors in the response (conceptual)
      if grep -q "errors" $out/response.json; then
        echo "GitHub GraphQL API returned errors:" >&2
        cat $out/response.json >&2
        exit 1
      fi

      echo "GitHub GraphQL query executed. Response in $out/response.json" >&2
    '';

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
      buildGraphQLQuery { inherit query variables; };

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
      }
      buildGraphQLQuery { inherit query variables; };
  };

in
{
  buildGraphQLQuery = buildGraphQLQuery;
  executeGraphQLQuery = executeGraphQLQuery;
  exampleQueries = exampleQueries;
}
