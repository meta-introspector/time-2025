{ lib, pkgs }:

{
  # Submodules from context/pick-up-nix/.gitmodules (Part 1)
  "vendor-rust-index-guix" = {
    path = "vendor/rust-index-guix";
    url = "https://github.com/meta-introspector/rust-index-guix";
    branch = null; # Not specified
  };
  "github-actions-install-nix-action" = {
    path = ".github/actions/install-nix-action";
    url = "https://github.com/meta-introspector/install-nix-action";
    branch = null;
  };
  "github-actions-nix-github-actions" = {
    path = ".github/actions/nix-github-actions";
    url = "https://github.com/meta-introspector/nix-github-actions";
    branch = null;
  };
  "github-actions-nix-installer-action" = {
    path = ".github/actions/nix-installer-action";
    url = "https://github.com/meta-introspector/nix-installer-action";
    branch = null;
  };
  "github-actions-cache-nix-action" = {
    path = ".github/actions/cache-nix-action";
    url = "https://github.com/meta-introspector/cache-nix-action";
    branch = null;
  };
  "github-actions-cache" = {
    path = ".github/actions/cache";
    url = "https://github.com/meta-introspector/cache";
    branch = null;
  };
  "github-actions-checkout" = {
    path = ".github/actions/checkout";
    url = "https://github.com/meta-introspector/checkout";
    branch = null;
  };
  "vendor-rnix-parser" = {
    path = "vendor/rnix-parser";
    url = "https://github.com/nix-community/rnix-parser";
    branch = null;
  };
  "github-actions-upload-artifact" = {
    path = ".github/actions/upload-artifact";
    url = "https://github.com/meta-introspector/upload-artifact";
    branch = null;
  };
  "vendor-nix-on-droid" = {
    path = "vendor/nix-on-droid";
    url = "https://github.com/nix-community/nix-on-droid";
    branch = null;
  };
  "vendor-nix-nix" = {
    path = "vendor/nix/nix";
    url = "https://github.com/NixOS/nix";
    branch = null;
  };
  "source-github-jmikedupont2-orgs-Escaped-RDFa-namespace" = {
    path = "source/github/jmikedupont2/orgs/Escaped-RDFa/namespace";
    url = "https://github.com/Escaped-RDFa/namespace";
    branch = null;
  };
  "source-github-meta-introspector-git-submodule-tools-rs" = {
    path = "source/github/meta-introspector/git-submodule-tools-rs";
    url = "https://github.com/meta-introspector/git-submodule-tools-rs";
    branch = null;
  };
  "vendor-external-git-submodule-tools-rs" = {
    path = "vendor/external/git-submodule-tools-rs";
    url = "https://github.com/meta-introspector/git-submodule-tools-rs";
    branch = null;
  };
  "source-github-meta-introspector-solfunmeme" = {
    path = "source/github/meta-introspector/solfunmeme";
    url = "https://github.com/meta-introspector/solfunmeme";
    branch = null;
  };
}
