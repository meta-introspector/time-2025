Name

    nix develop - run a bash shell that provides the build environment of a derivation

Synopsis

    nix develop [option...] installable

Examples

      · Start a shell with the build environment of the default package of the flake in the current directory:
        
          | # nix develop
        
        Typical commands to run inside this shell are:
        
          | # configurePhase
          | # buildPhase
          | # installPhase
        
        Alternatively, you can run whatever build tools your project uses directly, e.g. for a typical Unix project:
        
          | # ./configure --prefix=$out
          | # make
          | # make install
lines 1-28 
    
      · Run a particular build phase directly:
        
          | # nix develop --unpack
          | # nix develop --configure
          | # nix develop --build
          | # nix develop --check
          | # nix develop --install
          | # nix develop --installcheck
    
      · Start a shell with the build environment of GNU Hello:
        
          | # nix develop nixpkgs#hello
    
      · Record a build environment in a profile:
        
          | # nix develop --profile /tmp/my-build-env nixpkgs#hello
    
      · Use a build environment previously recorded in a profile:
        
          | # nix develop /tmp/my-build-env
    
      · Replace all occurrences of the store path corresponding to glibc.dev with a writable directory:
        
          | # nix develop --redirect nixpkgs#glibc.dev ~/my-glibc/outputs/dev
        
        Note that this is useful if you're running a nix develop shell for nixpkgs#glibc in ~/my-glibc and want to compile another package
        against it.
    
lines 30-57 
      · Run a series of script commands:
        
          | # nix develop --command bash -c "mkdir build && cmake .. && make"

Description

    nix develop starts a bash shell that provides an interactive build environment nearly identical to what Nix would use to build 
    installable. Inside this shell, environment variables and shell functions are set up so that you can interactively and incrementally
    build your package.

    Nix determines the build environment by building a modified version of the derivation installable that just records the environment
    initialised by stdenv and exits. This build environment can be recorded into a profile using --profile.

    The prompt used by the bash shell can be customised by setting the bash-prompt, bash-prompt-prefix, and bash-prompt-suffix settings in 
    nix.conf or in the flake's nixConfig attribute.

Flake output attributes

    If no flake output attribute is given, nix develop tries the following flake output attributes:

      · devShells.<system>.default
    
      · packages.<system>.default

    If a flake output name is given, nix develop tries the following flake output attributes:

      · devShells.<system>.<name>
    
      · packages.<system>.<name>
lines 59-86 
    
      · legacyPackages.<system>.<name>

Options

      · --build Run the build phase.
    
      · --check Run the check phase.
    
      · --command / -c command args Instead of starting an interactive shell, start the specified command and arguments.
    
      · --configure Run the configure phase.
    
      · --ignore-environment / -i Clear the entire environment (except those specified with --keep).
    
      · --install Run the install phase.
    
      · --installcheck Run the installcheck phase.
    
      · --keep / -k name Keep the environment variable name.
    
      · --phase phase-name The stdenv phase to run (e.g. build or configure).
    
      · --profile path The profile to operate on.
    
      · --redirect installable outputs-dir Redirect a store path to a mutable location.
    
      · --unpack Run the unpack phase.
    
lines 88-115 
      · --unset / -u name Unset the environment variable name.

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
          | -I /etc/nixos
        
        will cause Nix to look for paths relative to /home/eelco/Dev and /etc/nixos, in that order. This is equivalent to setting the 
        NIX_PATH environment variable to
        
          | /home/eelco/Dev:/etc/nixos
        
        It is also possible to match paths against a prefix. For example, passing
lines 117-144 
        
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
        
          | -I nixpkgs=flake:nixpkgs
        
        specifies that the prefix nixpkgs shall refer to the source tree downloaded from the nixpkgs entry in the flake registry. Similarly,
        
          | -I nixpkgs=flake:github:NixOS/nixpkgs/nixos-22.05
        
        makes <nixpkgs> refer to a particular branch of the NixOS/nixpkgs repository on GitHub.
    
lines 146-173 
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
    
      · --update-input input-path Update a specific flake input (ignoring its previous entry in the lock file).

    Logging-related options:

      · --debug Set the logging verbosity level to 'debug'.
    
      · --log-format format Set the format of log output; one of raw, internal-json, bar or bar-with-logs.
lines 175-202 
    
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

    Options that change the interpretation of installables:

      · --expr expr Interpret installables as attribute paths relative to the Nix expression expr.
    
      · --file / -f file Interpret installables as attribute paths relative to the Nix expression stored in file. If file is the character -,
        then a Nix expression will be read from standard input. Implies --impure.

lines 204-231 
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
    
      · --auto-allocate-uids Enable the auto-allocate-uids setting.
    
      · --auto-optimise-store Enable the auto-optimise-store setting.
    
      · --bash-prompt value Set the bash-prompt setting.
    
      · --bash-prompt-prefix value Set the bash-prompt-prefix setting.
lines 233-260 
    
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
    
      · --diff-hook value Set the diff-hook setting.
    
      · --download-attempts value Set the download-attempts setting.
    
      · --download-speed value Set the download-speed setting.
    
      · --eval-cache Enable the eval-cache setting.
    
lines 262-289 
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
    
      · --extra-platforms value Set the extra-platforms setting.
    
      · --extra-plugin-files value Append to the plugin-files setting.
    
      · --extra-sandbox-paths value Append to the sandbox-paths setting.
    
      · --extra-secret-key-files value Append to the secret-key-files setting.

    

