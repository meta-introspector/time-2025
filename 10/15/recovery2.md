# Uncommitted Changes - 2025-10-15

## Git Status

```
On branch feature/aimyc-003-cultivation
Your branch is up to date with 'origin/feature/aimyc-003-cultivation'.

Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
  (use "git restore <file>..." to discard changes in working directory)
  (commit or discard the untracked or modified content in submodules)
	modified:   09/26/jobs/vendor/nix-task (modified content)
	modified:   09/26/synapse-system (modified content)
	modified:   10/12/proof/vendor/rnix-parser (modified content)
	modified:   flake.nix

no changes added to commit (use "git add" and/or "git commit -a")
```

## Git Diff HEAD

```diff
diff --git a/09/26/jobs/vendor/nix-task b/09/26/jobs/vendor/nix-task
--- a/09/26/jobs/vendor/nix-task
+++ b/09/26/jobs/vendor/nix-task
@@ -1 +1 @@
-Subproject commit d85d91c1b7c00bf5868738a9a05446825af106e5
+Subproject commit d85d91c1b7c00bf5868738a9a05446825af106e5-dirty
diff --git a/09/26/synapse-system b/09/26/synapse-system
--- a/09/26/synapse-system
+++ b/09/26/synapse-system
@@ -1 +1 @@
-Subproject commit 9906109a062e33ded891790dcefa26373f09ffa1
+Subproject commit 9906109a062e33ded891790dcefa26373f09ffa1-dirty
diff --git a/10/12/proof/vendor/rnix-parser b/10/12/proof/vendor/rnix-parser
--- a/10/12/proof/vendor/rnix-parser
+++ b/10/12/proof/vendor/rnix-parser
@@ -1 +1 @@
-Subproject commit a84cdbaf50709e4c22d88f015a87dcbf935def9e
+Subproject commit a84cdbaf50709e4c22d88f015a87dcbf935def9e-dirty
diff --git a/flake.nix b/flake.nix
index 9125594..c974b01 100644
--- a/flake.nix
+++ b/flake.nix
@@ -97,14 +97,10 @@
         flake-utils = { url = githubWrapper { owner = "meta-introspector"; repo = "flake-utils"; ref = "feature/CRQ-016-nixify"; }; };
       };
     };
-    # Import the githubWrapper utility
-    githubWrapperLib = {
-      url = "./lib/github-wrapper.nix";
-      flake = false; # It's a Nix file, not a flake
-    };
+    githubWrapper = { url = ./lib/github-wrapper.nix; flake = false; };
   };
 
-  outputs = { self, nixpkgs, flake-utils, rnix-parser, nixTaskNew, nix-stdlib, nixOntologyRepo, month10Flake, sops-nix, nixIntrospector, logAnalyzer, node2nix-src, nurl, spore-vial, dataSources, readMdVial, readRsVial, githubWrapperLib }:
+  outputs = { self, nixpkgs, flake-utils, rnix-parser, nixTaskNew, nix-stdlib, nixOntologyRepo, month10Flake, sops-nix, nixIntrospector, logAnalyzer, node2nix-src, nurl, spore-vial, dataSources, readMdVial, readRsVial, githubWrapper }:
     let
       # Define mycologyWorkflow as nixTask
       mycologyWorkflow = nixTaskNew;
@@ -114,8 +110,6 @@
       pkgs = import nixpkgs { inherit system; };
       inherit (pkgs) lib;
 
-      githubWrapper = import githubWrapperLib { inherit lib; };
-
       # Import the secrets module and get the sopsSecretsPath option
       secretsModule = import ./lib/secrets.nix { inherit lib; };
       sopsSecretsPath = secretsModule.options.sopsSecretsPath.default; # Access the default value
```
