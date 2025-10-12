{ pkgs, lib, self }:

pkgs.runCommand "nix-file-list"
{
  nativeBuildInputs = [ pkgs.findutils ]; # For the 'find' command
  # The project source is implicitly available via 'self'
  # We need to ensure 'self' is a path, which it is in a flake context
  projectRoot = self;
} ''
  # Create the output directory
  mkdir -p $out/index/chunks

  # Find all .nix files within the projectRoot and write their absolute paths to nix.txt
  # We use -L to follow symlinks, which 'self' might be.
  # We use -print0 and xargs -0 to handle filenames with spaces or special characters.
  find -L $projectRoot -type f -name "*.nix" -print0 | xargs -0 realpath > $out/index/chunks/nix.txt

  echo "Generated Nix file list at $out/index/chunks/nix.txt"
''
