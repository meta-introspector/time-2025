
let
  pkgs = import <nixpkgs> {};
  inherit (pkgs) lib;
  wrap_context_def = import ./wrap_context.nix;

  pickupnix_context = wrap_context_def.wrap_context {
    inherit lib;
    paths = [ /data/data/com.termux.nix/files/home/pick-up-nix2 ];
    name = "pickupnix";
  };

  streamofrandom_context = wrap_context_def.wrap_context {
    inherit lib;
    paths = [ /data/data/com.termux.nix/files/home/pick-up-nix2/source/github/meta-introspector/streamofrandom ];
    name = "streamofrandom";
  };

  time2025_context = wrap_context_def.wrap_context {
    inherit lib;
    paths = [ /data/data/com.termux.nix/files/home/pick-up-nix2/source/github/meta-introspector/streamofrandom/2025 ];
    name = "time-2025";
  };

in
{
  pickupnix = pickupnix_context;
  streamofrandom = streamofrandom_context;
  time2025 = time2025_context;
}
