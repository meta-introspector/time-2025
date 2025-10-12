{ pkgs, githubApiUrl, ... }:

let
  # An impure Nix derivation to execute a GraphQL query against the GitHub API.
  # This requires a GitHub Personal Access Token (PAT).
  executeGraphQLQuery =
    { queryPayload
    , # The JSON payload constructed by buildGraphQLQuery
      githubToken
    , # GitHub Personal Access Token (PAT)
      name ? "github-graphql-query"
    ,
    }:
    pkgs.runCommand name
      {
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
in
executeGraphQLQuery
