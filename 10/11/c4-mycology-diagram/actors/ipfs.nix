{ lib, ... }:

{
  systems = [
    { id = "ipfs"; name = "IPFS Network"; description = "Decentralized network for spreading Spores (immutable data artifacts)."; }
  ];

  relationships = [
    { from = "aiMycelium"; to = "ipfs"; description = "Spreads via (data artifacts)"; }
  ];
}