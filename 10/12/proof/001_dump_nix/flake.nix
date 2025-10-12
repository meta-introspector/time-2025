# 10/12/proof/001_dump_nix/flake.nix
{
  description = "A flake to dump the AST of all .nix files in the parent project.";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
    flake-utils.url = "github:meta-introspector/flake-utils?ref=feature/CRQ-016-nixify";
    # Reference the parent project's flake to access qa.nix
    parentProject.url = "path:../../..";
  };

  outputs = { self, nixpkgs, flake-utils, parentProject }:
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
                projectRoot = parentProject;
                buildInputs = [ pkgs.nix ]; # Ensure nix is available for nix eval
              } ''
              echo "--- Running nix eval --json on $nixFile ---"
              mkdir -p $out/share/nix-dumps
              nix eval --json --file "$projectRoot/$nixFile" > "$out/share/nix-dumps/${packageName}.dump"
              echo "--- Finished nix eval --json on $nixFile ---"
            '';
          }
        )
        allNixFiles);

      # Create a meta-package that depends on all individual dump packages
      allNixDumps = pkgs.stdenv.mkDerivation {
        pname = "all-nix-dumps";
        version = "0.1.0";
        propagatedBuildInputs = lib.map (x: toString x.out) (lib.attrValues dumpPackages);
        src = ./.; # Dummy source to satisfy mkDerivation
        dontBuild = true;
        dontInstall = true;
      };
    in
    {
      packages.${system}.default = allNixDumps; # Expose the meta-package as default

      apps.${system}.dump-nix-ast = {
        type = "app";
        program = "${allNixDumps}/bin/nix-dump-evaluator"; # This will run the meta-package's script if it had one, or just build it
      };
      apps.${system}.default = self.apps.${system}.dump-nix-ast;
    };
}
