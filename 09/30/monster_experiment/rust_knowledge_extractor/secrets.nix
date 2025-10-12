{ config, lib, pkgs, ... }:

{
  sops.secrets = {
    google_accounts = {
      sopsFile = ./sops-secrets/google_accounts.json;
    };
  };
}
