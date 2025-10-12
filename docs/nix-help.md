no


sh-5.2$  nix build path:./flakes/predicate-analyzer#nixFileListGenerator --help
WARNING: terminal is not fully functional
Press RETURN to continue 

      | Warning 
      | This program is experimental and its interface is subject to change.

Name

    nix build - build a derivation or fetch a store path

Synopsis

    nix build [option...] installables...

Examples

lines 1-13...skipping...
      | Warning 
      | This program is experimental and its interface is subject to change.

Name

    nix build - build a derivation or fetch a store path

Synopsis

    nix build [option...] installables...

Examples

      · Build the default package from the flake in the current directory:
        
          | # nix build
    
      · Build and run GNU Hello from the nixpkgs flake:
        
          | # nix build nixpkgs#hello
          | # ./result/bin/hello
          | Hello, world!
    
      · Build GNU Hello and Cowsay, leaving two result symlinks:
        
          | # nix build nixpkgs#hello nixpkgs#cowsay
          | # ls -l result*
          | lrwxrwxrwx 1 … result -> /nix/store/v5sv61sszx301i0x6xysaqzla09nksnd-hello-2.10
lines 1-28
          | lrwxrwxrwx 1 … result-1 -> /nix/store/rkfrm0z6x6jmi7d3gsmma4j53h15mg33-cowsay-3.03+dfsg2
lines 2-29 
    
      · Build GNU Hello and print the resulting store path.
        
          | # nix build nixpkgs#hello --print-out-paths
          | /nix/store/v5sv61sszx301i0x6xysaqzla09nksnd-hello-2.10
    
      · Build a specific output:
        
          | # nix build nixpkgs#glibc.dev
          | # ls -ld ./result-dev
          | lrwxrwxrwx 1 … ./result-dev -> /nix/store/dkm3gwl0xrx0wrw6zi5x3px3lpgjhlw4-glibc-2.32-dev
    
      · Build attribute build.x86_64-linux from (non-flake) Nix expression release.nix:
        
          | # nix build --file release.nix build.x86_64-linux
    
      · Build a NixOS system configuration from a flake, and make a profile point to the result:
        
          | # nix build --profile /nix/var/nix/profiles/system \
          |   ~/my-configurations#nixosConfigurations.machine.config.system.build.toplevel
        
        (This is essentially what nixos-rebuild does.)
    
      · Build an expression specified on the command line:
        
          | # nix build --impure --expr \
          |   'with import <nixpkgs> {};
          |    runCommand "foo" {
          |      buildInputs = [ hello ];
lines 31-58 
          |    }
          |    "hello > $out"'
          | # cat ./result
          | Hello, world!
        
        Note that --impure is needed because we're using <nixpkgs>, which relies on the $NIX_PATH environment variable.
    
      · Fetch a store path from the configured substituters, if it doesn't already exist:
        
          | # nix build /nix/store/rkfrm0z6x6jmi7d3gsmma4j53h15mg33-cowsay-3.03+dfsg2

Description

    nix build builds the specified installables. Installables that resolve to derivations are built (or substituted if possible). Store path
    installables are substituted.

    Unless --no-link is specified, after a successful build, it creates symlinks to the store paths of the installables. These symlinks have
    the prefix ./result by default; this can be overridden using the --out-link option. Each symlink has a suffix -<N>-<outname>, where N is
    the index of the installable (with the left-most installable having index 0), and outname is the symbolic derivation output name (e.g. 
    bin, dev or lib). -<N> is omitted if N = 0, and -<outname> is omitted if outname = out (denoting the default output).

Options

      · --dry-run Show what this command would do without doing it.
    
      · --json Produce output in JSON format, suitable for consumption by another program.
    
      · --no-link Do not create symlinks to the build results.
    
lines 60-87 
      · --out-link / -o path Use path as prefix for the symlinks to the build results. It defaults to result.
    
      · --print-out-paths Print the resulting output paths
    
      · --profile path The profile to operate on.
    
      · --rebuild Rebuild an already built package and compare the result to the existing store paths.
    
      · --stdin Read installables from the standard input. No default installable applied.

    Common evaluation options:

      · --arg name expr Pass the value expr as the argument name to Nix functions.
    
      · --argstr name string Pass the string string as the argument name to Nix functions.
    
      · --debugger Start an interactive environment if evaluation fails.
    
      · --eval-store store-url The URL of the Nix store to use for evaluation, i.e. to store derivations (.drv files) and inputs referenced
        by them.
    
      · --impure Allow access to mutable paths and repositories.
    
      · --include / -I path Add path to the Nix search path. The Nix search path is initialized from the colon-separated NIX_PATH environment
        variable, and is used to look up the location of Nix expressions using paths enclosed in angle brackets (i.e., <nixpkgs>).
        
        For instance, passing
        
          | -I /home/eelco/Dev
lines 89-116 
          | -I /etc/nixos
        
        will cause Nix to look for paths relative to /home/eelco/Dev and /etc/nixos, in that order. This is equivalent to setting the 
        NIX_PATH environment variable to
        
          | /home/eelco/Dev:/etc/nixos
        
        It is also possible to match paths against a prefix. For example, passing
        
          | -I nixpkgs=/home/eelco/Dev/nixpkgs-branch
          | -I /etc/nixos
        
        will cause Nix to search for <nixpkgs/path> in /home/eelco/Dev/nixpkgs-branch/path and /etc/nixos/nixpkgs/path.
        
        If a path in the Nix search path starts with http:// or https://, it is interpreted as the URL of a tarball that will be downloaded
        and unpacked to a temporary location. The tarball must consist of a single top-level directory. For example, passing
        
          | -I nixpkgs=https://github.com/NixOS/nixpkgs/archive/master.tar.gz
        
        tells Nix to download and use the current contents of the master branch in the nixpkgs repository.
        
        The URLs of the tarballs from the official nixos.org channels (see the manual page for nix-channel) can be abbreviated as 
        channel:<channel-name>. For instance, the following two flags are equivalent:
        
          | -I nixpkgs=channel:nixos-21.05
          | -I nixpkgs=https://nixos.org/channels/nixos-21.05/nixexprs.tar.xz
        
        You can also fetch source trees using flake URLs and add them to the search path. For instance,
        
lines 118-145 
          | -I nixpkgs=flake:nixpkgs
        
        specifies that the prefix nixpkgs shall refer to the source tree downloaded from the nixpkgs entry in the flake registry. Similarly,
        
          | -I nixpkgs=flake:github:NixOS/nixpkgs/nixos-22.05
        
        makes <nixpkgs> refer to a particular branch of the NixOS/nixpkgs repository on GitHub.
    
      · --override-flake original-ref resolved-ref Override the flake registries, redirecting original-ref to resolved-ref.

    Common flake-related options:

      · --commit-lock-file Commit changes to the flake's lock file.
    
      · --inputs-from flake-url Use the inputs of the specified flake as registry entries.
    
      · --no-registries Don't allow lookups in the flake registries. This option is deprecated; use --no-use-registries.
    
      · --no-update-lock-file Do not allow any updates to the flake's lock file.
    
      · --no-write-lock-file Do not write the flake's newly generated lock file.
    
      · --output-lock-file flake-lock-path Write the given lock file instead of flake.lock within the top-level flake.
    
      · --override-input input-path flake-url Override a specific flake input (e.g. dwarffs/nixpkgs). This implies --no-write-lock-file.
    
      · --recreate-lock-file Recreate the flake's lock file from scratch.
    
      · --reference-lock-file flake-lock-path Read the given lock file instead of flake.lock within the top-level flake.
lines 147-174 
    
      · --update-input input-path Update a specific flake input (ignoring its previous entry in the lock file).

    Logging-related options:

      · --debug Set the logging verbosity level to 'debug'.
    
      · --log-format format Set the format of log output; one of raw, internal-json, bar or bar-with-logs.
    
      · --print-build-logs / -L Print full build logs on standard error.
    
      · --quiet Decrease the logging verbosity level.
    
      · --verbose / -v Increase the logging verbosity level.

    Miscellaneous global options:

      · --help Show usage information.
    
      · --offline Disable substituters and consider all previously downloaded files up-to-date.
    
      · --option name value Set the Nix configuration setting name to value (overriding nix.conf).
    
      · --refresh Consider all previously downloaded files out-of-date.
    
      · --repair During evaluation, rewrite missing or corrupted files in the Nix store. During building, rebuild missing or corrupted store
        paths.
    
      · --version Show version information.
lines 176-203 

    Options that change the interpretation of installables:

      · --expr expr Interpret installables as attribute paths relative to the Nix expression expr.
    
      · --file / -f file Interpret installables as attribute paths relative to the Nix expression stored in file. If file is the character -,
        then a Nix expression will be read from standard input. Implies --impure.

    Options to override configuration settings:

      · --accept-flake-config Enable the accept-flake-config setting.
    
      · --access-tokens value Set the access-tokens setting.
    
      · --allow-dirty Enable the allow-dirty setting.
    
      · --allow-import-from-derivation Enable the allow-import-from-derivation setting.
    
      · --allow-new-privileges Enable the allow-new-privileges setting.
    
      · --allow-symlinked-store Enable the allow-symlinked-store setting.
    
      · --allow-unsafe-native-code-during-evaluation Enable the allow-unsafe-native-code-during-evaluation setting.
    
      · --allowed-impure-host-deps value Set the allowed-impure-host-deps setting.
    
      · --allowed-uris value Set the allowed-uris setting.
    
      · --allowed-users value Set the allowed-users setting.
lines 205-232 
    
      · --auto-allocate-uids Enable the auto-allocate-uids setting.
    
      · --auto-optimise-store Enable the auto-optimise-store setting.
    
      · --bash-prompt value Set the bash-prompt setting.
    
      · --bash-prompt-prefix value Set the bash-prompt-prefix setting.
    
      · --bash-prompt-suffix value Set the bash-prompt-suffix setting.
    
      · --build-hook value Set the build-hook setting.
    
      · --build-poll-interval value Set the build-poll-interval setting.
    
      · --build-users-group value Set the build-users-group setting.
    
      · --builders value Set the builders setting.
    
      · --builders-use-substitutes Enable the builders-use-substitutes setting.
    
      · --commit-lockfile-summary value Set the commit-lockfile-summary setting.
    
      · --compress-build-log Enable the compress-build-log setting.
    
      · --connect-timeout value Set the connect-timeout setting.
    
      · --cores value Set the cores setting.
    
lines 234-261 
      · --diff-hook value Set the diff-hook setting.
    
      · --download-attempts value Set the download-attempts setting.
    
      · --download-speed value Set the download-speed setting.
    
      · --eval-cache Enable the eval-cache setting.
    
      · --experimental-features value Set the experimental-features setting.
    
      · --extra-access-tokens value Append to the access-tokens setting.
    
      · --extra-allowed-impure-host-deps value Append to the allowed-impure-host-deps setting.
    
      · --extra-allowed-uris value Append to the allowed-uris setting.
    
      · --extra-allowed-users value Append to the allowed-users setting.
    
      · --extra-build-hook value Append to the build-hook setting.
    
      · --extra-experimental-features value Append to the experimental-features setting.
    
      · --extra-extra-platforms value Append to the extra-platforms setting.
    
      · --extra-hashed-mirrors value Append to the hashed-mirrors setting.
    
      · --extra-ignored-acls value Append to the ignored-acls setting.
    
      · --extra-nix-path value Append to the nix-path setting.
lines 263-290 
    
      · --extra-platforms value Set the extra-platforms setting.
    
      · --extra-plugin-files value Append to the plugin-files setting.
    
      · --extra-sandbox-paths value Append to the sandbox-paths setting.
    
      · --extra-secret-key-files value Append to the secret-key-files setting.
    
      · --extra-substituters value Append to the substituters setting.
    
      · --extra-system-features value Append to the system-features setting.
    
      · --extra-trusted-public-keys value Append to the trusted-public-keys setting.
    
      · --extra-trusted-substituters value Append to the trusted-substituters setting.
    
      · --extra-trusted-users value Append to the trusted-users setting.
    
      · --fallback Enable the fallback setting.
    
      · --filter-syscalls Enable the filter-syscalls setting.
    
      · --flake-registry value Set the flake-registry setting.
    
      · --fsync-metadata Enable the fsync-metadata setting.
    
      · --gc-reserved-space value Set the gc-reserved-space setting.
    
lines 292-319 
      · --hashed-mirrors value Set the hashed-mirrors setting.
    
      · --http-connections value Set the http-connections setting.
    
      · --http2 Enable the http2 setting.
    
      · --id-count value Set the id-count setting.
    
      · --ignore-try Enable the ignore-try setting.
    
      · --ignored-acls value Set the ignored-acls setting.
    
      · --impersonate-linux-26 Enable the impersonate-linux-26 setting.
    
      · --keep-build-log Enable the keep-build-log setting.
    
      · --keep-derivations Enable the keep-derivations setting.
    
      · --keep-env-derivations Enable the keep-env-derivations setting.
    
      · --keep-failed Enable the keep-failed setting.
    
      · --keep-going Enable the keep-going setting.
    
      · --keep-outputs Enable the keep-outputs setting.
    
      · --log-lines value Set the log-lines setting.
    
      · --max-build-log-size value Set the max-build-log-size setting.
lines 321-348 
    
      · --max-free value Set the max-free setting.
    
      · --max-jobs value Set the max-jobs setting.
    
      · --max-silent-time value Set the max-silent-time setting.
    
      · --max-substitution-jobs value Set the max-substitution-jobs setting.
    
      · --min-free value Set the min-free setting.
    
      · --min-free-check-interval value Set the min-free-check-interval setting.
    
      · --nar-buffer-size value Set the nar-buffer-size setting.
    
      · --narinfo-cache-negative-ttl value Set the narinfo-cache-negative-ttl setting.
    
      · --narinfo-cache-positive-ttl value Set the narinfo-cache-positive-ttl setting.
    
      · --netrc-file value Set the netrc-file setting.
    
      · --nix-path value Set the nix-path setting.
    
      · --no-accept-flake-config Disable the accept-flake-config setting.
    
      · --no-allow-dirty Disable the allow-dirty setting.
    
      · --no-allow-import-from-derivation Disable the allow-import-from-derivation setting.
    
lines 350-377 
      · --no-allow-new-privileges Disable the allow-new-privileges setting.
    
      · --no-allow-symlinked-store Disable the allow-symlinked-store setting.
    
      · --no-allow-unsafe-native-code-during-evaluation Disable the allow-unsafe-native-code-during-evaluation setting.
    
      · --no-auto-allocate-uids Disable the auto-allocate-uids setting.
    
      · --no-auto-optimise-store Disable the auto-optimise-store setting.
    
      · --no-builders-use-substitutes Disable the builders-use-substitutes setting.
    
      · --no-compress-build-log Disable the compress-build-log setting.
    
      · --no-eval-cache Disable the eval-cache setting.
    
      · --no-fallback Disable the fallback setting.
    
      · --no-filter-syscalls Disable the filter-syscalls setting.
    
      · --no-fsync-metadata Disable the fsync-metadata setting.
    
      · --no-http2 Disable the http2 setting.
    
      · --no-ignore-try Disable the ignore-try setting.
    
      · --no-impersonate-linux-26 Disable the impersonate-linux-26 setting.
    
      · --no-keep-build-log Disable the keep-build-log setting.
lines 379-406 
    
      · --no-keep-derivations Disable the keep-derivations setting.
    
      · --no-keep-env-derivations Disable the keep-env-derivations setting.
    
      · --no-keep-failed Disable the keep-failed setting.
    
      · --no-keep-going Disable the keep-going setting.
    
      · --no-keep-outputs Disable the keep-outputs setting.
    
      · --no-preallocate-contents Disable the preallocate-contents setting.
    
      · --no-print-missing Disable the print-missing setting.
    
      · --no-pure-eval Disable the pure-eval setting.
    
      · --no-require-drop-supplementary-groups Disable the require-drop-supplementary-groups setting.
    
      · --no-require-sigs Disable the require-sigs setting.
    
      · --no-restrict-eval Disable the restrict-eval setting.
    
      · --no-run-diff-hook Disable the run-diff-hook setting.
    
      · --no-sandbox Disable sandboxing.
    
      · --no-sandbox-fallback Disable the sandbox-fallback setting.
    
lines 408-435 
      · --no-show-trace Disable the show-trace setting.
    
      · --no-substitute Disable the substitute setting.
    
      · --no-sync-before-registering Disable the sync-before-registering setting.
    
      · --no-trace-function-calls Disable the trace-function-calls setting.
    
      · --no-trace-verbose Disable the trace-verbose setting.
    
      · --no-use-case-hack Disable the use-case-hack setting.
    
      · --no-use-cgroups Disable the use-cgroups setting.
    
      · --no-use-registries Disable the use-registries setting.
    
      · --no-use-sqlite-wal Disable the use-sqlite-wal setting.
    
      · --no-use-xdg-base-directories Disable the use-xdg-base-directories setting.
    
      · --no-warn-dirty Disable the warn-dirty setting.
    
      · --plugin-files value Set the plugin-files setting.
    
      · --post-build-hook value Set the post-build-hook setting.
    
      · --pre-build-hook value Set the pre-build-hook setting.
    
      · --preallocate-contents Enable the preallocate-contents setting.
lines 437-464 
    
      · --print-missing Enable the print-missing setting.
    
      · --pure-eval Enable the pure-eval setting.
    
      · --relaxed-sandbox Enable sandboxing, but allow builds to disable it.
    
      · --require-drop-supplementary-groups Enable the require-drop-supplementary-groups setting.
    
      · --require-sigs Enable the require-sigs setting.
    
      · --restrict-eval Enable the restrict-eval setting.
    
      · --run-diff-hook Enable the run-diff-hook setting.
    
      · --sandbox Enable sandboxing.
    
      · --sandbox-build-dir value Set the sandbox-build-dir setting.
    
      · --sandbox-dev-shm-size value Set the sandbox-dev-shm-size setting.
    
      · --sandbox-fallback Enable the sandbox-fallback setting.
    
      · --sandbox-paths value Set the sandbox-paths setting.
    
      · --secret-key-files value Set the secret-key-files setting.
    
      · --show-trace Enable the show-trace setting.
    
lines 466-493 
      · --ssl-cert-file value Set the ssl-cert-file setting.
    
      · --stalled-download-timeout value Set the stalled-download-timeout setting.
    
      · --start-id value Set the start-id setting.
    
      · --store value Set the store setting.
    
      · --substitute Enable the substitute setting.
    
      · --substituters value Set the substituters setting.
    
      · --sync-before-registering Enable the sync-before-registering setting.
    
      · --system value Set the system setting.
    
      · --system-features value Set the system-features setting.
    
      · --tarball-ttl value Set the tarball-ttl setting.
    
      · --timeout value Set the timeout setting.
    
      · --trace-function-calls Enable the trace-function-calls setting.
    
      · --trace-verbose Enable the trace-verbose setting.
    
      · --trusted-public-keys value Set the trusted-public-keys setting.
    
      · --trusted-substituters value Set the trusted-substituters setting.
lines 495-522 
    
      · --trusted-users value Set the trusted-users setting.
    
      · --use-case-hack Enable the use-case-hack setting.
    
      · --use-cgroups Enable the use-cgroups setting.
    
      · --use-registries Enable the use-registries setting.
    
      · --use-sqlite-wal Enable the use-sqlite-wal setting.
    
      · --use-xdg-base-directories Enable the use-xdg-base-directories setting.
    
      · --user-agent-suffix value Set the user-agent-suffix setting.
    
      · --warn-dirty Enable the warn-dirty setting.

lines 512-539/539 (END) 
lines 512-539/539 (END)q
sh-5.2$ sh-5.2$ 
