# foaf.nix
{
  pkgs ? import <nixpkgs> {},
  # The flake's self input, which points to the directory containing this file
  self,
}:

let
  # Path to the generated foaf.jsonld file
  # It's relative to the flake's root, which is 'self'
  foafJsonLdFile = self + /foaf.jsonld;

  # Read and parse the JSON-LD file
  # Use builtins.path to ensure the file is in the Nix store before reading
  foafData = builtins.fromJSON (builtins.readFile foafJsonLdFile);

  # Helper function to find entities by type
  findEntitiesByType = type:
    builtins.filter (entity:
      (builtins.isAttrs entity && entity ? "@type" && entity."@type" == type) ||
      (builtins.isString entity."@type" && entity."@type" == type)
    ) foafData."@graph";

  # Helper function to find projects made by a specific owner
  findProjectsByMaker = makerId:
    builtins.filter (project:
      project ? "maker" && project.maker ? "@id" && project.maker."@id" == makerId
    ) (findEntitiesByType "Project");

in {
  # Expose the raw parsed data
  raw = foafData;

  # Expose functions to query the data
  getAgents = findEntitiesByType "Agent";
  getProjects = findEntitiesByType "Project";
  getProjectsByMaker = makerId: findProjectsByMaker makerId;

  # Example usage:
  # nix-instantiate --eval -E 'with import ./foaf.nix {}; getProjects'
  # nix-instantiate --eval -E 'with import ./foaf.nix {}; getProjectsByMaker "http://github.com/meta-introspector"'
}
