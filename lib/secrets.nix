{ lib, ... }:

{
  ##  options.sopsSecretsPath = lib.mkOption {
  ##    type = lib.types.str;
  ##    default = self + "/sops-secrets"; # Path to sops-secrets relative to the flake root
  ##    description = "The path to the sops-secrets directory.";
  ##  };
}
