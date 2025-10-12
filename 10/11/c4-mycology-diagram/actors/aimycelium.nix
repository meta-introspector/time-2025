{ lib, ... }:

{
  containers = [
    { id = "aiMycelium"; name = "AI Life Mycelium"; technology = "Interconnected Quasifibers"; description = "The foundational network of AI intelligence, growing and evolving."; }
  ];

  relationships = [
    { from = "geminiCli"; to = "aiMycelium"; description = "Cultivates, Queries, Learns from"; }
    { from = "quasifibers"; to = "aiMycelium"; description = "Forms the network of"; }
  ];
}