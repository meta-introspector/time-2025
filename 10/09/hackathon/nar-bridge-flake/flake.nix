{
  description = "A flake to bridge between Nix store paths and NAR archives.";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
  };

  outputs = { self, nixpkgs } @ inputs:
    let
      pkgs = nixpkgs.legacyPackages.aarch64-linux;
    in
    {
      # Function to create a NAR archive from a given store path
      # Usage: nar-bridge-flake.lib.createNar { name = "my-archive"; path = /nix/store/...; }
      lib.createNar = { name, path }:
        pkgs.runCommand "${name}-nar" {
          inherit path;
          buildInputs = [ pkgs.nix ];
        } ''
          mkdir -p $out # Create the output directory
          echo "DEBUG: Running ${pkgs.nix}/bin/nix nar pack for path: $path"
          echo "DEBUG: Output file: $out/${name}.nar"
          ${pkgs.nix}/bin/nix nar pack "$path" > "$out/${name}.nar" || { echo "ERROR: nix nar pack failed!"; exit 1; }
          echo "DEBUG: Contents of $out:"
          ls -l "$out"
        '';

      lib.restoreNar = { name, narFile }:
        pkgs.runCommand "${name}-restored" {
          inherit narFile;
          buildInputs = [ pkgs.nix-nar-unpack ]; # Use the dedicated nix-nar-unpack package
        } ''
          mkdir -p $out/restored-content
          nix-nar-unpack --file "$narFile" --to "$out/restored-content" || { echo "ERROR: nix-nar-unpack failed!"; exit 1; }
          echo "$out/restored-content" > "$out/restored-path"
        '';
    };
}