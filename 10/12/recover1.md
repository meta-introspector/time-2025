# Local Changes for Crash Recovery - October 12, 2025

This document details the local, unstaged, and untracked changes identified on October 12, 2025, for crash recovery purposes.

## Unstaged Changes

### Modified Submodules (indicated by '-dirty' in git status)

The following submodules have local modifications that are not yet staged:

*   **09/22/crq-binstore**:
    ```diff
    --- a/09/22/crq-binstore
    +++ b/09/22/crq-binstore
    @@ -1 +1 @@
    -Subproject commit 444c2af1f714572196d34b8c94fe6746cdef9863
    +Subproject commit 444c2af1f714572196d34b8c94fe6746cdef9863-dirty
    ```

*   **09/26/jobs/vendor/nix-eval-jobs**:
    ```diff
    --- a/09/26/jobs/vendor/nix-eval-jobs
    +++ b/09/26/jobs/vendor/nix-eval-jobs
    @@ -1 +1 @@
    -Subproject commit a3e6c7a20ddcf52f6da260024a7ec783e335019b
    +Subproject commit a3e6c7a20ddcf52f6da260024a7ec783e335019b-dirty
    ```

*   **09/26/jobs/vendor/nix-task**:
    ```diff
    --- a/09/26/jobs/vendor/nix-task
    +++ b/09/26/jobs/vendor/nix-task
    @@ -1 +1 @@
    -Subproject commit 045f89b90b2b5a1402c24b19f4b642e7b704e1f5
    +Subproject commit 045f89b90b2b5a1402c24b19f4b642e7b704e1f5-dirty
    ```

*   **09/26/synapse-system**:
    ```diff
    --- a/09/26/synapse-system
    +++ b/09/26/synapse-system
    @@ -1 +1 @@
    -Subproject commit 54a91926f98d626f859b94d8f9068f6e030b26af
    +Subproject commit 54a91926f98d626f859b94d8f9068f6e030b26af-dirty
    ```

### Modified File: `10/12/proof/flake.nix`

This file has unstaged modifications related to the `nix-to-solana-translator`.

```diff
diff --git a/10/12/proof/flake.nix b/10/12/proof/flake.nix
index 38db8bf..ca29204 100644
--- a/10/12/proof/flake.nix
+++ b/10/12/proof/flake.nix
@@ -9,10 +9,11 @@
     rnix-dumper.url = "path:./000_rnix_dump";
     nar-exporter.url = "path:./001_nar_exporter";
     binstore-locator.url = "path:./002_binstore_locator";
+    nix-to-solana-translator.url = "path:./004_nix_to_solana_translator";
     # nix-dumper.url = "path:./001_dump_nix";
   };
 
-  outputs = { self, nixpkgs, flake-utils, streamofrandom, rnix-dumper, nar-exporter, binstore-locator }:
+  outputs = { self, nixpkgs, flake-utils, streamofrandom, rnix-dumper, nar-exporter, binstore-locator, nix-to-solana-translator }:
     flake-utils.lib.eachDefaultSystem (system:
       let
         pkgs = nixpkgs.legacyPackages.${system};
@@ -116,7 +117,8 @@
           rnixDumpCheck = rnixDumpCheckResult;
           # nixDumpCheck = nixDumpCheck; # Commented out
           default = combinedProofReport;
-          narBinstoreLocator = binstore-locator.packages.${system}.default; # New check
+          narBinstoreLocator = binstore-locator.packages.${system}.default;
+          solanaTranslator = nix-to-solana-translator.packages.${system}.default; # New check
         };
         apps.registry-demo = {
           type = "app";
```

## Untracked Files/Directories

The following directory is untracked by Git:

*   `10/12/proof/004_nix_to_solana_translator/`

## Staged for Commit (for context)

The following files are staged and ready to be committed:

*   `10/12/grandvision.md`
*   `10/12/proof/solana.nix`
