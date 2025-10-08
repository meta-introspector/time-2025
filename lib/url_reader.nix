{ lib, pkgs, builtins, ... }:

{
  fetchImpureUrl = { url, name ? "fetched-url-content" }:
    pkgs.runCommand name {
      inherit url;
      __impure = true; # Allow impure operations
      nativeBuildInputs = [ pkgs.curl ]; # Use curl to fetch the URL
    } ''
      mkdir -p $out
      curl -L -o $out/content.html "${url}"
    '';
}