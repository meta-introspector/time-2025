{
  description = "Nix flake for parsing CRQ filenames into structured data.";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
    flake-utils.url = "github:meta-introspector/flake-utils?ref=feature/CRQ-016-nixify";

  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ ];
        };
      in
      {
        packages.default = pkgs.runCommand "crq-parser-success"
          {
            meta.description = "Nix flake for parsing CRQ filenames into structured data.";
          } ''
          echo 'CRQ Parser flake built successfully!' > $out
        '';

        lib = {
          parseCrqFilename = filename:
            if builtins.match "^CRQ_[0-9]{3}_.*\.md$" filename != null then {
              crqId = builtins.substring 4 7 filename;
              title = builtins.substring 12 ((builtins.stringLength filename) - 3) filename;
              kind = "crq";
            } else if builtins.match "^INCIDENT_[0-9]{3}_.*\.md$" filename != null then {
              incidentId = builtins.substring 10 7 filename;
              title = builtins.substring 18 ((builtins.stringLength filename) - 3) filename;
              kind = "incident";
            } else if builtins.match "^TASK_[0-9]{3}_.*\.md$" filename != null then {
              taskId = builtins.substring 5 7 filename;
              title = builtins.substring 13 ((builtins.stringLength filename) - 3) filename;
              kind = "task";
            } else
              null;
        };
      });
}
