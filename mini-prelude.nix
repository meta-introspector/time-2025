
{
  pkgs ? import <nixpkgs> {},
  lib ? pkgs.lib,
}:

let
  # Import the raw createContext function
  rawCreateContext = import ./createContext.nix;

  # Define a recursive helper function to create contexts
  makeContext = { path, name }: rawCreateContext {
    inherit lib pkgs path name;
  };

  # Define the root paths for the contexts
  pickUpNixRoot = /data/data/com.termux.nix/files/home/pick-up-nix2;
  streamOfRandomRoot = /data/data/com.termux.nix/files/home/pick-up-nix2/source/github/meta-introspector/streamofrandom;
  time2025Root = /data/data/com.termux.nix/files/home/pick-up-nix2/source/github/meta-introspector/streamofrandom/2025;

  # Create contexts for each root path
  pickUpNixContext = makeContext { path = pickUpNixRoot; name = "pick-up-nix"; };
  streamOfRandomContext = makeContext { path = streamOfRandomRoot; name = "streamofrandom"; };
  time2025Context = makeContext { path = time2025Root; name = "time-2025"; };

in
  pickUpNixContext.nixFiles ++ streamOfRandomContext.nixFiles ++ time2025Context.nixFiles
