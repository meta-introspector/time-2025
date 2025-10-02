{ lib, pkgs, builtins }: {
  indexNixFiles = { path, projectRoot, name ? "nix-file-index" }:
    pkgs.runCommand name {
      inherit path projectRoot;
      __impure = true;
      nativeBuildInputs = [ pkgs.findutils pkgs.nix pkgs.gnused ];
    }
    ''
      mkdir -p $out
      echo "[" > $out/nix-files.index.json
      FIRST=true
      find "${path}" -type f -name "*.nix" -print0 | while IFS= read -r -d $'\0' file; do
          file_hash=$(nix hash file --sri "$file")
          relative_path=$(echo "$file" | sed "s|^${projectRoot}/||")
          printf '  {"path": "%s", "hash": "%s"}' "$relative_path" "$file_hash" >> $out/nix-files.index.json
        FIRST=false
      done
      echo "]" >> $out/nix-files.index.json
    '';
}
