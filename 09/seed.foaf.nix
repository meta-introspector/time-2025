# seed.foaf.nix
{
  pkgs ? import <nixpkgs> {},
  self,
}:

let
  # Define the FOAF context
  foafContext = "http://xmlns.com/foaf/0.1/";

  # Function to create a FOAF Agent
  mkAgent = { id, name, homepage }:
    {
      "@id" = id;
      "@type" = "foaf:Agent";
      "foaf:name" = name;
      "foaf:homepage" = { "@id" = homepage; };
    };

  # Function to create a FOAF Project
  mkProject = { id, name, homepage, description, makerId }:
    {
      "@id" = id;
      "@type" = "foaf:Project";
      "foaf:name" = name;
      "foaf:homepage" = { "@id" = homepage; };
      "dcterms:description" = description;
      "foaf:maker" = { "@id" = makerId; };
    };

  # Define owners
  jmikedupont2 = mkAgent {
    id = "http://github.com/jmikedupont2";
    name = "jmikedupont2";
    homepage = "http://github.com/jmikedupont2";
  };
  metaIntrospector = mkAgent {
    id = "http://github.com/meta-introspector";
    name = "meta-introspector";
    homepage = "http://github.com/meta-introspector";
  };
  h4ck3rm1k3 = mkAgent {
    id = "http://github.com/h4ck3rm1k3";
    name = "h4ck3rm1k3";
    homepage = "http://github.com/h4ck3rm1k3";
  };

  # Collect all agents
  agents = [
    jmikedupont2
    metaIntrospector
    h4ck3rm1k3
  ];

  # Collect all projects
  projects = [
    # jmikedupont2 repositories (sample)
    (mkProject { id = "https://github.com/jmikedupont2/rnix-eval"; name = "rnix-eval"; homepage = "https://github.com/jmikedupont2/rnix-eval"; description = ""; makerId = jmikedupont2.id; })
    (mkProject { id = "https://github.com/jmikedupont2/pick-up-nix"; name = "pick-up-nix"; homepage = "https://github.com/jmikedupont2/pick-up-nix"; description = ""; makerId = jmikedupont2.id; })
    (mkProject { id = "https://github.com/jmikedupont2/rust-analyzer"; name = "rust-analyzer"; homepage = "https://github.com/jmikedupont2/rust-analyzer"; description = "A Rust compiler front-end for IDEs"; makerId = jmikedupont2.id; })
    (mkProject { id = "https://github.com/jmikedupont2/o1js"; name = "o1js"; homepage = "https://github.com/jmikedupont2/o1js"; description = "Performance tuning tools for o1js, the TypeScript framework for zk-SNARKs and zkApps. Github actions to run docker containers with linux perf recordings of o1js jest tests. Also runs locally. "; makerId = jmikedupont2.id; })
    # ... (other jmikedupont2 repos would go here) ...

    # meta-introspector repositories (sample)
    (mkProject { id = "https://github.com/meta-introspector/time-2025"; name = "time-2025"; homepage = "https://github.com/meta-introspector/time-2025"; description = "Repository for time-stamped data and logs for the year 2025."; makerId = metaIntrospector.id; })
    (mkProject { id = "https://github.com/meta-introspector/lean4"; name = "lean4"; homepage = "https://github.com/meta-introspector/lean4"; description = "Lean 4 programming language and theorem prover"; makerId = metaIntrospector.id; })
    (mkProject { id = "https://github.com/meta-introspector/rust"; name = "rust"; homepage = "https://github.com/meta-introspector/rust"; description = "Empowering everyone to build reliable and efficient software."; makerId = metaIntrospector.id; })
    # ... (other meta-introspector repos would go here) ...

    # h4ck3rm1k3 repositories (sample)
    (mkProject { id = "https://github.com/h4ck3rm1k3/ai-agent-terraform-zkp"; name = "ai-agent-terraform-zkp"; homepage = "https://github.com/h4ck3rm1k3/ai-agent-terraform-zkp"; description = "Terraform framework for deploying [elizaos/eliza, mina zkapps, swarms] ai agents"; makerId = h4ck3rm1k3.id; })
    (mkProject { id = "https://github.com/h4ck3rm1k3/sweble-wikitext"; name = "sweble-wikitext"; homepage = "https://github.com/h4ck3rm1k3/sweble-wikitext"; description = "sweble the wikipedia parser wikitext "; makerId = h4ck3rm1k3.id; })
    # ... (other h4ck3rm1k3 repos would go here) ...
  ];

  # Combine agents and projects into a graph
  graph = agents ++ projects;

in {
  "@context" = foafContext;
  "@graph" = graph;
}
