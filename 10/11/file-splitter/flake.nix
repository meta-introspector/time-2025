{
  description = "Nix flake for splitting a list of files by extension.";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify-workflow";
    flake-utils.url = "github:meta-introspector/flake-utils?ref=feature/CRQ-016-nixify-workflow";
    self = {
      url = "github:meta-introspector/time-2025?ref=feature/CRQ-016-nixify-workflow"; # Project root
    };
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        inherit (nixpkgs) lib;

        # The split_files_by_extension.sh script
        splitFilesScript = "${self}/index/split_files_by_extension.sh";

        # Function to split a files.txt into chunks by extension
        splitFilesByExtension = { filesList, name ? "split-files-by-extension" }:
          pkgs.runCommand name
            {
              nativeBuildInputs = [ pkgs.bash ];
              script = splitFilesScript;
              files = filesList;
            } ''
            echo "Splitting files from ${files} by extension..."
            # The script expects files.txt as input and creates output in current dir
            cp ${files} files.txt
            bash $script
            # Move the generated chunk directories to $out
            mkdir -p $out
            mv chunks $out/
            echo "Files split by extension into $out/chunks/"
          '';

      in
      {
        lib = { inherit splitFilesByExtension; };
      }
    );
}
