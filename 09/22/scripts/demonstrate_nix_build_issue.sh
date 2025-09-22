#!/usr/bin/env bash

echo "Attempting to build 'enum-self' from its subdirectory using 'nix build'..."
echo "This command is expected to fail due to Nix version limitations."
echo ""

# Change to the enum-self directory and attempt to build
(cd enum-self && nix build)

# Capture the exit code of the last command
exit_code=$?

if [ $exit_code -ne 0 ]; then
    echo ""
    echo "-------------------------------------------------------------------"
    echo "BUILD FAILED as expected."
    echo "Reason: The current Nix environment's version is too old to fully"
    echo "support modern flake features, particularly the '--flake' flag"
    echo "and proper resolution of flakes in subdirectories."
    echo ""
    echo "Please refer to the Standard Operating Procedure (SOP) for details"
    echo "and solutions:"
    echo "docs/sops/nix_build_subdir_sop.md"
    echo "-------------------------------------------------------------------"
else
    echo ""
    echo "-------------------------------------------------------------------"
    echo "BUILD SUCCEEDED unexpectedly."
    echo "This indicates that the Nix environment has been updated or the"
    echo "issue has been resolved. Please verify the build output."
    echo "-------------------------------------------------------------------"
fi

exit $exit_code
