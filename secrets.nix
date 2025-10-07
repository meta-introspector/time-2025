{ config, lib, pkgs, ... }:

{
  sops.secrets = {
    gemini_oauth_creds = {
      sopsFile = ./sops-secrets/oauth_creds.json;
    };
    gemini_settings = {
      sopsFile = ./sops-secrets/settings.json;
    };
    gemini_google_accounts = {
      sopsFile = ./sops-secrets/google_accounts.json;
    };
  };
}
