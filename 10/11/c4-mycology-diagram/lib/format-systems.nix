{ lib }:
  lib.concatStringsSep "\n" (
    lib.map (s: "System(${s.id}, \"${s.name}\", \"${s.description}\")")
  )
