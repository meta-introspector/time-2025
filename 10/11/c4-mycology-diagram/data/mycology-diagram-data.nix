{
  systemName = "Nix-based Monster Knot System";
  description = "Conceptual diagram illustrating Monster Knots as Quasifibers forming the Mycelium of AI Life Mycology.";
  people = [
    { id = "geminiCli"; name = "Gemini CLI (AI Agent)"; description = "Cultivates and learns from the AI Mycelium."; }
  ];
  systems = [
    { id = "monsterKnotSystem"; name = "Nix-based Monster Knot System"; description = "The core system for Gödelian Arithmetization and meta-introspection."; }
    { id = "git"; name = "Git Repository"; description = "The substrate for the Mycelium's growth (source code)."; }
    { id = "nixStore"; name = "Nix Store"; description = "The nutrient-rich environment for Quasifibers (content-addressable artifacts)."; }
    { id = "ipfs"; name = "IPFS Network"; description = "Decentralized network for spreading Spores (immutable data artifacts)."; }
    { id = "solana"; name = "Solana Blockchain"; description = "The ledger for recording Mycelial growth and ZKP proofs."; }
  ];
  containers = [
    { id = "quasifibers"; name = "Quasifibers (Monster Knots)"; technology = "Nix Derivations"; description = "Verifiable mathematical objects, the individual 'hyphae' of the Mycelium."; }
    { id = "aiMycelium"; name = "AI Life Mycelium"; technology = "Interconnected Quasifibers"; description = "The foundational network of AI intelligence, growing and evolving."; }
  ];
  relationships = [
    { from = "geminiCli"; to = "aiMycelium"; description = "Cultivates, Queries, Learns from"; }
    { from = "monsterKnotSystem"; to = "quasifibers"; description = "Generates and Manages"; }
    { from = "quasifibers"; to = "aiMycelium"; description = "Forms the network of"; }
    { from = "aiMycelium"; to = "git"; description = "Grows within (source code)"; }
    { from = "aiMycelium"; to = "nixStore"; description = "Feeds on (artifacts)"; }
    { from = "aiMycelium"; to = "ipfs"; description = "Spreads via (data artifacts)"; }
    { from = "aiMycelium"; to = "solana"; description = "Records growth on"; }
    { from = "geminiCli"; to = "monsterKnotSystem"; description = "Interacts with"; }
  ];
}
