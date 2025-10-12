[
  {
    from = "geminiCli";
    to = "monsterKnotSystem";
    description = "Operates, Queries, Updates Mappings";
  }
  {
    from = "monsterKnotSystem";
    to = "git";
    description = "Reads/Writes Nix files, Tracks Changes";
  }
  {
    from = "monsterKnotSystem";
    to = "nixStore";
    description = "Stores/Retrieves NARs and Derivations";
  }
  {
    from = "monsterKnotSystem";
    to = "ipfs";
    description = "Stores/Retrieves Immutable Data Artifacts";
  }
  {
    from = "monsterKnotSystem";
    to = "solana";
    description = "Submits ZKP Proofs, Records Transactions";
  }
  {
    from = "monsterKnotSystem";
    to = "lmfdb";
    description = "Mirrors Data (Conceptual)";
  }
  {
    from = "geminiCli";
    to = "git";
    description = "Interacts with (commits, pushes)";
  }
  {
    from = "monsterKnotSystem";
    to = "lean4";
    description = "Invokes for Formal Verification (CRQ-012)";
  }
  {
    from = "monsterKnotSystem";
    to = "minizinc";
    description = "Utilizes for Constraint Modeling/Optimization";
  }
  {
    from = "monsterKnotSystem";
    to = "rust";
    description = "Integrates ZKP Provers and Tools";
  }
  {
    from = "rust";
    to = "llvm";
    description = "Compiles via";
  }
  {
    from = "monsterKnotSystem";
    to = "llvm";
    description = "Leverages for Code Analysis/Generation";
  }
]
