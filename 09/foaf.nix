{ pkgs, self, foafSeedData }:

let
  # Define the FOAF context
  foafContext = "http://xmlns.com/foaf/0.1/";
  # Seed FOAF data (agents and projects) is now passed as an argument

  # Import GitHub FOAF data
  githubFoafData = import ./github.foaf.nix { inherit pkgs lib fetchGithubData githubToFoaf; };

  # Import individual CRQ FOAF documents
  crq001 = import ./crq-001.foaf.nix { inherit pkgs lib; };
  crq007 = import ./crq-007.foaf.nix { inherit pkgs lib; };
  crq008 = import ./crq-008.foaf.nix { inherit pkgs lib; };
  crq009 = import ./crq-009.foaf.nix { inherit pkgs lib; };
  crq010 = import ./crq-010.foaf.nix { inherit pkgs lib; };
  crq011 = import ./crq-011.foaf.nix { inherit pkgs lib; };
  crq012 = import ./crq-012.foaf.nix { inherit pkgs lib; };
  crq013 = import ./crq-013.foaf.nix { inherit pkgs lib; };

  # Aggregate all CRQ FOAF documents
  allCrqs = import ./crqs.foaf.nix { inherit pkgs crq001 crq007 crq008 crq009 crq010 crq011 crq012 crq013 lib; };

  # Combine all FOAF entities into a single graph
  fullGraph = foafSeedData ++ allCrqs ++ githubFoafData.githubEntities;

  # Helper function to find entities by type
  findEntitiesByType = type:
    builtins.filter (entity:
      (builtins.isAttrs entity && entity ? "@type" && entity."@type" == type) ||
      (builtins.isString entity."@type" && entity."@type" == type)
    ) fullGraph;

  # Helper function to find projects made by a specific owner
  findProjectsByMaker = makerId:
    builtins.filter (project:
      project ? "maker" && project.maker ? "@id" && project.maker."@id" == makerId
    ) (findEntitiesByType "Project");

in {
  # Expose the raw parsed data
  raw = { "@context" = foafContext; "@graph" = fullGraph; };

  # Expose functions to query the data
  getAgents = findEntitiesByType "Agent";
  getProjects = findEntitiesByType "Project";
  getProjectsByMaker = findProjectsByMaker;
  getCrqs = allCrqs; # Expose all CRQs
  getGithubEntities = githubFoafData.githubEntities;

  # Example usage:
  # nix-instantiate --eval -E 'with import ./foaf.nix {}; getProjects'
  # nix-instantiate --eval -E 'with import ./foaf.nix {}; getProjectsByMaker "http://github.com/meta-introspector"'
  # nix-instantiate --eval -E 'with import ./foaf.nix {}; getCrqs'
}
