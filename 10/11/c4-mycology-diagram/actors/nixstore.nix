{ lib, ... }:

{
  systems = [
    { id = "nixStore"; name = "Nix Store"; description = "The nutrient-rich environment for Quasifibers (content-addressable artifacts)."; }
  ];

  relationships = [
    { from = "aiMycelium"; to = "nixStore"; description = "Feeds on (artifacts)"; }
  ];
}
