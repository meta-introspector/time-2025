
# 10/09/hackathon-update-prep.nix
# Nix meta-program for preparing daily hackathon updates.

{ pkgs, lib, ... }:

let
  colosseumUrl = "https://colosseum.com";
  colosseumHackathonPath = "/hackathon";

  # Derivation to fetch the main colosseum.com page
  colosseumHomepage = pkgs.stdenv.mkDerivation {
    pname = "colosseum-homepage";
    version = "latest"; # Or a date-based version
    dontUnpack = true;
    src = pkgs.fetchurl {
      url = colosseumUrl;
      sha256 = "cFDRewMK87as/u4zvtrKdxwEmSyaSH/M0Buq20Gb3zU="; # From previous successful fetch
    };
    installPhase = ''
      mkdir -p $out
      cp $src $out/index.html
    '';
  };

  # Derivation to fetch the colosseum.com/hackathon page
  colosseumHackathonPage = pkgs.stdenv.mkDerivation {
    pname = "colosseum-hackathon-page";
    version = "latest"; # Or a date-based version
    dontUnpack = true;
    src = pkgs.fetchurl {
      url = "${colosseumUrl}${colosseumHackathonPath}";
      # This sha256 will likely be incorrect and need to be updated after the first build attempt.
      sha256 = "ewR4CwoYHI0I+ugG3e491n/7cZ3fpW8L2ZSzSBLiRuo=";
    };
    installPhase = ''
      mkdir -p $out
      cp $src $out/index.html
    '';
  };

in
{
  # Expose the URLs and fetched derivations
  urls = {
    inherit colosseumUrl colosseumHackathonPath;
  };
  fetchedContent = {
    inherit colosseumHomepage colosseumHackathonPage;
  };
  # Later, we'll add structured data extracted from these pages.
}
