{ pkgs, lib, self }:

let
  umlData = {
    title = "Hackathon: Godelian Mycology Workflow (CRQ-012 Arithmetization)";
    boundary = {
      type = "System_Boundary";
      name = "Log Analyzer System";
      id = "logAnalyzerSystem";
    };
    elements = [
      # Define your elements here, e.g.:
      # { type = "Container"; name = "Nix Flake"; id = "nixFlake"; technology = "Nix"; description = "Manages project dependencies and builds"; }
    ];
    externals = [
      # Define external systems here, e.g.:
      # { type = "External_System"; name = "Telemetry Log"; id = "telemetryLog"; description = "Raw input log data"; }
    ];
    relationships = [
      # Define relationships here, e.g.:
      # { source = "telemetryLog"; destination = "logAnalyzerSystem"; description = "Sends log data to"; }
    ];
  };

  plantumlGenerator = import (self + "/lib/plantuml_generator.nix") {
    inherit lib umlData;
  };
in
# Final Nix derivation: produces a content-addressable PUML file
pkgs.writeText "hackathon-mycology-workflow.puml" (lib.strings.concatStringsSep "\n" plantumlGenerator.pumlLines)
