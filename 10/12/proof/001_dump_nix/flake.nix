# 10/12/proof/001_dump_nix/flake.nix
{
  description = "A flake to dump the AST of all .nix files in the parent project.";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
    flake-utils.url = "github:meta-introspector/flake-utils?ref=feature/CRQ-016-nixify";
    # Reference the parent project's flake to access qa.nix
    parentProject.url = "path:../../..";
    rnix-parser.url = "github:meta-introspector/rnix-parser?ref=feature/CRQ-016-nixify-workflow";
  };

  outputs = { self, nixpkgs, flake-utils, parentProject, rnix-parser }:
    let
      system = "aarch64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      lib = pkgs.lib;

      # Get all .nix files from the parent project
      allNixFiles = lib.filter (name: lib.hasSuffix ".nix" name) (builtins.attrNames (builtins.readDir parentProject));
      # Create individual dump packages for each .nix file
      dumpPackages = lib.listToAttrs (lib.map
        (nixFile:
          let
            packageName = lib.replaceStrings [ "/" "." ] [ "-" "-" ] nixFile;
          in
          {
            name = "dump-${packageName}";
            value = pkgs.runCommand "nix-dump-${packageName}"
              {
                inherit nixFile;
                projectRoot = builtins.toString parentProject;
                buildInputs = [ pkgs.nix ]; # Still need nix for nix eval
                analyzerPath = builtins.toString ./analyzer.nix; # Path to the new analyzer.nix as a string
              } ''
              echo "--- Analyzing $nixFile with analyzer.nix ---"
              mkdir -p $out/share/nix-dumps
              nix eval --json \
                --arg nixpkgs ${nixpkgs} \
                --arg rnixParser ${rnix-parser} \
                --argstr projectRoot "$projectRoot" \
                --argstr nixFile "$nixFile" \
                --expr "let pkgs = import (builtins.getFlake \"git:meta-introspector/nixpkgs\").legacyPackages.aarch64-linux; rnixParser = ${rnix-parser}; in (import $analyzerPath) { builtins = builtins; projectRoot = \"doesnotmatter\"; nixFile = \"$nixFile\"; pkgs = pkgs; lib = pkgs.lib; rnix-parser = rnixParser; }" \
                > "$out/share/nix-dumps/${packageName}.analysis.json"
              echo "--- Finished analyzing $nixFile ---"
            '';
          }
        )
        allNixFiles);

      # Create a meta-package that depends on all individual dump packages
      allNixDumps = pkgs.runCommand "all-nix-dumps-0.1.0"
        {
          nativeBuildInputs = [ pkgs.bash ];
          dumpOutputs = lib.map (x: x) (lib.attrValues dumpPackages);
        }
        ''
          mkdir -p $out/share/nix-dumps
          for dump in $dumpOutputs; do
            cp -r $dump/share/nix-dumps/* $out/share/nix-dumps/
          done
        '';
    in
    {
      packages.${system}.default = allNixDumps; # Expose the meta-package as default

      apps.${system}.dump-nix-ast = {
        type = "app";
        program = "${pkgs.writeShellScript "dump-nix-ast-app" ''
          echo "Path to all Nix dumps: ${allNixDumps}"
          ls -l ${allNixDumps}/share/nix-dumps
        ''}";
      };
      apps.${system}.default = self.apps.${system}.dump-nix-ast;
    };
}
