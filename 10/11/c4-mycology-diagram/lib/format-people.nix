{ lib }:
lib.concatStringsSep "\n" (
  lib.map (p: "Person(${p.id}, \"${p.name}\", \"${p.description}\")")
)
