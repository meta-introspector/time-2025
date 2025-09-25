let
  # Import nixpkgs
  pkgs = import (fetchTarball "https://github.com/meta-introspector/nixpkgs/archive/feature/CRQ-016-nixify.tar.gz") {};

  # Fetch gemini-cli source
  geminiCliSrc = pkgs.fetchFromGitHub {
    owner = "google-gemini";
    repo = "gemini-cli";
    rev = "main"; # Assuming 'main' branch, or a specific commit/tag
    sha256 = "sha256-r5mhHqM/rJ7FJML2BntWmlj9pxAHsVpAmt3tb6AcQE8="; # Placeholder, will need to update
  };

in
  pkgs.stdenv.mkDerivation {
    pname = "gemini-cli";
    version = "0.3.4";
    src = geminiCliSrc;

    buildInputs = [ pkgs.nodejs pkgs.git pkgs.ripgrep ]; # Add nodejs and git

    # Allow network access during the build for npm install
    # This is a hack and should be used with caution.
    # In a proper flake setup, this would be handled differently.
    __noChroot = true;
    __noSandbox = true;

    installPhase = ''
      # Manually run npm install
      npm install --prefix . --cache $TMPDIR/npm-cache --prefer-online

      # Original install steps from gemini-cli/flake.nix
      mkdir -p $out/{bin,share/gemini-cli}

      cp -r node_modules $out/share/gemini-cli/

      rm -f $out/share/gemini-cli/node_modules/@google/gemini-cli
      rm -f $out/share/gemini-cli/node_modules/@google/gemini-cli-core
      rm -f $out/share/gemini-cli/node_modules/@google/gemini-cli-a2a-server
      rm -f $out/share/gemini-cli/node_modules/@google/gemini-cli-test-utils
      rm -f $out/share/gemini-cli/node_modules/gemini-cli-vscode-ide-companion
      cp -r packages/cli $out/share/gemini-cli/node_modules/@google/gemini-cli
      cp -r packages/core $out/share/gemini-cli/node_modules/@google/gemini-cli-core
      cp -r packages/a2a-server $out/share/gemini-cli/node_modules/@google/gemini-cli-a2a-server

      ln -s $out/share/gemini-cli/node_modules/@google/gemini-cli/dist/index.js $out/bin/gemini
      chmod +x "$out/bin/gemini"
    '';
  }