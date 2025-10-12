{ lib, pkgs, builtins, ... }:

{
  extractUrls = { path, name ? "extracted-urls" }:
    pkgs.runCommand name
      {
        inherit path;
        nativeBuildInputs = [ pkgs.gnugrep ]; # Use grep to find URLs
        extractUrlsScript = pkgs.writeShellScript "extract-urls" ''
          mkdir -p $out
          grep -r -o -E "http(s)?://[^\"'<>[:space:]]+" "$path" > "$out"/urls.txt || true
        '';
      } ''
      bash $extractUrlsScript
    '';
}
