{ pkgs, lib, mycologyWorkflow, nixpkgs, nixIntrospector, dataSources, sopsSecretsPath, zosSporeVial, nixToPoemVial, readMdVial, readRsVial, ... }:

let
  # Import necessary modules
  makeContext = import ./lib/monad-context.nix { inherit pkgs lib; };
  allTasks = makeContext.generateTasks; # Get all tasks from the task generator

  # Read the list of Nix files from index.nix.txt
  nixFiles = pkgs.lib.splitString "\n" (builtins.readFile ./index.nix.txt);

  # Function to select the appropriate vial flake based on file extension
  selectVialFlake = filePath:
    let
      extension = pkgs.lib.last (pkgs.lib.splitString "." filePath);
    in
    if extension == "nix" then nixToPoemVial
    else if extension == "md" then readMdVial
    else if extension == "rs" then readRsVial
    else zosSporeVial; # Default vial

  orchestrate = globalState:
    let
      # ... existing let bindings ...

      # Get the first valid file path from the list
      firstValidFilePath = lib.head (lib.filter (f: f != "") nixFiles);

      # Select the appropriate vial flake for the first valid file
      selectedVialFlake = if firstValidFilePath != null then selectVialFlake firstValidFilePath else zosSporeVial; # Fallback

      # Invoke mycologyWorkflow with the first valid file path and the selected vial flake
      fruitingBody = if firstValidFilePath != null then mycologyWorkflow.outputs.default {
        inherit nixpkgs dataSources;
        flake-utils = nixIntrospector;
        vial = selectedVialFlake; # Pass the selected vial flake
        filePath = firstValidFilePath; # Pass the file path
        mycologyContext = { inherit sopsSecretsPath; };
      } else null; # Handle case where no valid file is found
    in
    # For now, let's just return the fruitingBody
    fruitingBody;

in
orchestrate getGlobalState
