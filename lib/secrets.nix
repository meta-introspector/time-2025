{ lib, ... }:

{
  options.sopsSecretsPath = lib.mkOption {
    type = lib.types.str;
    default = "~/sops-secrets"; # Default to home directory
    description = "The path to the sops-secrets directory.";
  };
}
