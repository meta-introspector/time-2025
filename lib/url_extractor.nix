{ lib, pkgs, builtins, ... }:

{
  extractUrls = { path, name ? "extracted-urls" }:
    pkgs.runCommand name {
      inherit path;
      nativeBuildInputs = [ pkgs.gnugrep ]; # Use grep to find URLs
    } ''
      mkdir -p $out
      # Find all files in the path and extract URLs using grep
      # This regex is a basic attempt to find http(s):// URLs
      grep -r -o -E "http(s)?://[^"'<>[:space:]]+" "$path" > $out/urls.txt || true
    '';
}
