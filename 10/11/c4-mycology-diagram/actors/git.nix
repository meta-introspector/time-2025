{ lib, ... }:

{
  systems = [
    { id = "git"; name = "Git Repository"; description = "The substrate for the Mycelium's growth (source code)."; }
  ];

  relationships = [
    { from = "aiMycelium"; to = "git"; description = "Grows within (source code)"; }
  ];
}