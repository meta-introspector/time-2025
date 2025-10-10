{ lib, pkgs }:

let
  # Path to the .gitmodules file for pick-up-nix context
  pickUpNixGitmodulesPath = ../../context/pick-up-nix/.gitmodules;
  # Path to the .gitmodules file for streamofrandom context
  streamOfRandomGitmodulesPath = ../../context/streamofrandom/.gitmodules;

  # Function to parse a .gitmodules file
  parseGitmodules = gitmodulesPath:
    let
      content = builtins.readFile gitmodulesPath;
      # Regex to find submodule sections
      submoduleSections = lib.strings.match ''^\[submodule "([^"]+)"\]\n\s*path = ([^\n]+)\n\s*url = ([^\n]+)(\n\s*branch = ([^\n]+))?'' content;
      # This regex is very basic and will need refinement for robustness

      # Function to extract info from a single match
      extractSubmoduleInfo = match:
        let
          name = lib.head match.captures;
          path = lib.head (lib.tail match.captures);
          url = lib.head (lib.tail (lib.tail match.captures));
          branch = if (lib.length match.captures) > 4 then lib.head (lib.tail (lib.tail (lib.tail (lib.tail match.captures)))) else null;
        in
        { inherit name path url branch; };
    in
    lib.map extractSubmoduleInfo submoduleSections;

  # Parse .gitmodules files
  pickUpNixSubmodules = if builtins.pathExists pickUpNixGitmodulesPath then parseGitmodules pickUpNixGitmodulesPath else [];
  streamOfRandomSubmodules = if builtins.pathExists streamOfRandomGitmodulesPath then parseGitmodules streamOfRandomGitmodulesPath else [];

  # Combine all submodules
  allContextSubmodules = pickUpNixSubmodules ++ streamOfRandomSubmodules;

  # Create explicit lookups for submodules
  submoduleLookups = lib.listToAttrs (lib.map (sub: {
    inherit (sub) name;
    value = sub;
  }) allContextSubmodules);

in
{
  # Expose submodule lookups
  inherit submoduleLookups;
  # Expose the raw list of submodules
  inherit allContextSubmodules;
}
