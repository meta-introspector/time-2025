{ lib, ... }:

{
  formatRelationships = relationships:
    lib.concatStringsSep "\n" (
      lib.map (r: "Rel(${r.from}, ${r.to}, \"${r.description}\")") relationships
    );
}