# Bug Report: nix-on-droid switch --flake .#android fails with "environment.pathsToLink does not exist"

**Date:** September 9, 2025

**Reported By:** Gemini CLI

**Severity:** High (Prevents successful `nix-on-droid` configuration switch)

**Description:**
Attempting to run `nix-on-droid switch --flake .#android` results in a build failure with the error message: "error: The option `environment.pathsToLink` does not exist." This issue prevents the successful application of the Android Nix configuration.

**Steps to Reproduce:**
1. Ensure the current working directory is `/data/data/com.termux.nix/files/home/pick-up-nix`.
2. Execute the command: `nix-on-droid switch --flake .#android --show-trace`

**Expected Behavior:**
The `nix-on-droid switch` command should complete successfully, applying the Android Nix configuration without errors.

**Actual Behavior:**
The command fails with the following error trace:

```
Building activation package...
warning: Git tree '/data/data/com.termux.nix/files/home/pick-up-nix' is dirty
error:
       … while evaluating a branch condition

         at /nix/store/3wqs0zryk11j09mhllxsnnaxpswvjfnp-source/modules/default.nix:33:5: 

           32|   module = 
           33|     if failedAssertions != [ ]
             |     ^ 
           34|     then throw "\nFailed assertions:\n${concatMapStringsSep "\n" (x: "- ${x}") failedAssertions}"

       … while calling the 'map' builtin

         at /nix/store/3wqs0zryk11j09mhllxsnnaxpswvjfnp-source/modules/default.nix:30:22: 

           29| 
           30|   failedAssertions = map (x: x.message) (filter (x: !x.assertion) rawModule.config.assertions); 
             |                      ^ 
           31| 

       … while calling the 'filter' builtin

         at /nix/store/3wqs0zryk11j09mhllxsnnaxpswvjfnp-source/modules/default.nix:30:42: 

           29| 
           30|   failedAssertions = map (x: x.message) (filter (x: !x.assertion) rawModule.config.assertions); 
             |                                          ^ 
           31| 

       … while evaluating the attribute 'config.assertions'

         at /nix/store/lv9bmgm6v1wc3fiz00v29gi4rk13ja6l-source/lib/modules.nix:322:9: 

          321|         options = checked options; 
          322|         config = checked (removeAttrs config [ "_module" ]); 
             |         ^ 
          323|         _module = checked (config._module); 

       … while calling the 'seq' builtin

         at /nix/store/lv9bmgm6v1wc3fiz00v29gi4rk13ja6l-source/lib/modules.nix:322:18: 

          321|         options = checked options; 
          322|         config = checked (removeAttrs config [ "_module" ]); 
             |                  ^ 
          323|         _module = checked (config._module); 

       … while calling the 'throw' builtin

         at /nix/store/lv9bmgm6v1wc3fiz00v29gi4rk13ja6l-source/lib/modules.nix:298:18: 

          297|                     '' 
          298|             else throw baseMsg 
             |                  ^ 
          299|         else null; 

       error: The option `environment.pathsToLink' does not exist. Definition values:
       - In `/nix/store/ichnhfn1n8l7m6pc15g3fi800qhg5y5w-source/nixos/common.nix`
```

**Additional Information:**
The error message suggests that `environment.pathsToLink` is an unrecognized option, possibly due to a version mismatch or a change in NixOS/Nixpkgs. The `strace` command used for debugging was:
`strace -o test.txt -f -s9999 nix-on-droid switch --flake .#android --show-trace`

The relevant line from the `strace` output was:
`see         environment.pathsToLink = [ "/etc/profile.d" ];`
