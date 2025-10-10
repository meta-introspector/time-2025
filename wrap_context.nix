{ lib, path, name }:
    let
      # Helper function to parse a .gitmodules file
      parseGitmodules = gitmodulesPath:
        let
          content = builtins.readFile gitmodulesPath;
          # Regex to find submodule sections
          # This regex is basic and might need refinement for robustness
          submoduleSections = lib.strings.match 
            (builtins.fromJSON "[ \"^\\[submodule \\\"([^\\\"]+)\\\"\\]\\n\\\\s*path = ([^\\\\n]+)\\\\n\\\\s*url = ([^\\\\n]+)(?:\\\\n\\\\s*branch = ([^\\\\n]+))?\"]")
            content;

          # Function to extract info from a single match
          extractSubmoduleInfo = match:
            let
              name = lib.elemAt match 0;
              subPath = lib.elemAt match 1;
              url = lib.elemAt match 2;
              branch = if (lib.length match) > 3 then lib.elemAt match 3 else null;
            in
            { inherit name subPath url branch; };
        in
        lib.map extractSubmoduleInfo submoduleSections;

      # Get .nix files in the current path
      nixFiles = lib.filter (
        file: builtins.match ".*\\.nix" file != null
      ) (builtins.attrNames (builtins.readDir path));

      # Get submodules in the current path
      gitmodulesPath = path + "/.gitmodules";
      submodulesRaw = if builtins.pathExists gitmodulesPath then parseGitmodules gitmodulesPath else [];

      # Recursively process submodules
      submoduleContexts = lib.listToAttrs (
        lib.map (
          sub: { 
            inherit (sub) name;
            value = wrap_context { inherit lib; path = path + "/" + sub.subPath; inherit (sub) name; };
          }
        ) submodulesRaw
      );

    in
    {
      inherit name;
      files = map (file: path + "/" + file) nixFiles;
      inherit submoduleContexts;
    }