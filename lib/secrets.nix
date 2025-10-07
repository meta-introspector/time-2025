{ lib, ... }:

{
  options.sopsSecretsPath = lib.mkOption {
    type = lib.types.str;
    default = "/data/data/com.termux.nix/files/home/pick-up-nix2/source/github/meta-introspector/streamofrandom/2025/sops-secrets"; # Absolute path to sops-secrets
    description = "The path to the sops-secrets directory.";
  };
}
