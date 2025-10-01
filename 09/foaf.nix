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

  # Import individual CRQ FOAF documents
  crq001 = import ./crq-001.foaf.nix { inherit pkgs; lib = pkgs.lib; };
  crq007 = import ./crq-007.foaf.nix { inherit pkgs; lib = pkgs.lib; };
  crq008 = import ./crq-008.foaf.nix { inherit pkgs; lib = pkgs.lib; };
  crq009 = import ./crq-009.foaf.nix { inherit pkgs; lib = pkgs.lib; };
  crq010 = import ./crq-010.foaf.nix { inherit pkgs; lib = pkgs.lib; };
  crq011 = import ./crq-011.foaf.nix { inherit pkgs; lib = pkgs.lib; };
  crq012 = import ./crq-012.foaf.nix { inherit pkgs; lib = pkgs.lib; };
  crq013 = import ./crq-013.foaf.nix { inherit pkgs; lib = pkgs.lib; };

  # Aggregate all CRQ FOAF documents
  allCrqs = import ./crqs.foaf.nix { inherit pkgs crq001 crq007 crq008 crq009 crq010 crq011 crq012 crq013; lib = pkgs.lib; };

in {
  # Expose the raw parsed data
  raw = foafData;

  # Expose functions to query the data
  getAgents = findEntitiesByType "Agent";
  getProjects = findEntitiesByType "Project";
  getProjectsByMaker = makerId: findProjectsByMaker makerId;
  getCrqs = allCrqs; # Expose all CRQs

  # Example usage:
  # nix-instantiate --eval -E 'with import ./foaf.nix {}; getProjects'
  # nix-instantiate --eval -E 'with import ./foaf.nix {}; getProjectsByMaker "http://github.com/meta-introspector"'
  # nix-instantiate --eval -E 'with import ./foaf.nix {}; getCrqs'
}
