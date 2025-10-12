{ lib, ... }:

{
  systems = [
    { id = "solana"; name = "Solana Blockchain"; description = "The ledger for recording Mycelial growth and ZKP proofs."; }
  ];

  relationships = [
    { from = "aiMycelium"; to = "solana"; description = "Records growth on"; }
  ];
}
