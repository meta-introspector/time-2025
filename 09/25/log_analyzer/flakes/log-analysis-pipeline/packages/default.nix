{ pkgs, ... } @ args:

import ./analysis.nix args // {
  # You can override or add to the default package here if needed
}
