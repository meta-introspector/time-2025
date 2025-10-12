{
  description = import ./lib/flake-description.nix;

  inputs = import ./lib/flake-inputs.nix;

  outputs = import ./lib/outputs-structure.nix;
}