(import ./commit-msg-check.nix { pkgs = import <nixpkgs> {}; }).overrideAttrs (oldAttrs: { 
    buildCommand = ''
      ${oldAttrs.buildCommand}
      # Pass the commit message file to the Nix expression
      ${oldAttrs.buildCommand} --argstr commitMsgFile \"${COMMIT_MSG_FILE}\"
    '';
  })