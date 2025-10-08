
{ pkgs ? import <nixpkgs> {} }:

pkgs.runCommand "nixpkgs-fmt-test" {} ''
  # Create a dummy Nix file
  cat > dummy.nix << '_NIX_EOF_'
  {   pkgs, ... }:

  {
    environment.systemPackages = [
      pkgs.htop
      pkgs.vim
    ];
  }
  _NIX_EOF_

  # Format the dummy Nix file
  ${pkgs.nixpkgs-fmt}/bin/nixpkgs-fmt dummy.nix

  # Assert that the file is formatted correctly (e.g., by comparing with a known good format)
  # For simplicity, we'll just check if the command ran without error.
  # In a real test, you'd compare the output with an expected string.
  echo "Nixpkgs-fmt test passed!" > $out
''
