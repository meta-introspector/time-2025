# github-to-foaf.nix
{ pkgs, lib, ... }:

let
  # Define GitHub and FOAF namespaces for convenience
  githubNs = "https://github.com/ontology/";
  foafNs = "http://xmlns.com/foaf/0.1/";
  dctermsNs = "http://purl.org/dc/terms/";

  # Function to convert a GitHub repository JSON object to a FOAF Project
  repoToFoaf = repoJson:
    {
      "@id" = repoJson.html_url; # Use repository URL as ID
      "@type" = "github:Repository"; # Use our defined GitHub Repository type
      "${foafNs}name" = repoJson.name;
      "${dctermsNs}description" = repoJson.description or "";
      "${foafNs}homepage" = { "@id" = repoJson.homepage or repoJson.html_url; };
      "${foafNs}maker" = { "@id" = repoJson.owner.html_url; }; # Assuming owner is the maker
      "${githubNs}hasOwner" = { "@id" = repoJson.owner.html_url; };
      # Add more properties as needed
    };

  # Function to convert a GitHub user JSON object to a FOAF Agent
  userToFoaf = userJson:
    {
      "@id" = userJson.html_url; # Use user URL as ID
      "@type" = "github:User"; # Use our defined GitHub User type
      "${foafNs}name" = userJson.login;
      "${foafNs}homepage" = { "@id" = userJson.html_url; };
      # Add more properties as needed
    };

in {
  inherit repoToFoaf;
  inherit userToFoaf;
}
