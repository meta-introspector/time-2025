{ lib, ... }:

let
  aspect29Imported = (import ./71-aspects-part-c-aspect-29-otel-event-trace.nix { inherit lib; }).aspect29;

  aspectsOf71 = [
    aspect29Imported
  ];
in aspectsOf71
