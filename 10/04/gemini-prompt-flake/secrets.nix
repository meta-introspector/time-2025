{ config, lib, pkgs, ... }:

{
  sops.secrets = {
    gemini_oauth_creds = {
      sopsFile = ./sops-secrets/oauth_creds.json;
      # This will be decrypted to $SOPS_SECRETS_DIR/gemini_oauth_creds
    };
    gemini_settings = {
      sopsFile = ./sops-secrets/settings.json;
    };
    gemini_google_accounts = {
      sopsFile = ./sops-secrets/google_accounts.json;
    };
  };
}
