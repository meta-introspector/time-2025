let
  # Define pkgs for the test environment
  pkgs = import <nixpkgs> { system = "aarch64-linux"; };

  # Get the nar-bridge-flake outputs
  narBridgeFlake = (builtins.getFlake (toString ./.)).outputs;

  # 1. Create a dummy derivation
  dummyDerivation = pkgs.runCommand "my-dummy-output" {} ''
    mkdir -p $out
    echo "Hello from dummy derivation!" > $out/hello.txt
  '';

  # 2. Use createNar to archive it
  archivedNar = narBridgeFlake.lib.createNar {
    name = "dummy-archive";
    path = dummyDerivation;
  };

  # 3. Use restoreNar to restore the archive
  restoredPath = narBridgeFlake.lib.restoreNar {
    name = "restored-dummy";
    narFile = archivedNar;
  };

  # 4. Verify the restored path
  testResult = pkgs.runCommand "test-nar-bridge" {
    inherit restoredPath;
    buildInputs = [ pkgs.diffutils ];
  } ''
    # Read the actual restored path from the file
    ACTUAL_RESTORED_PATH=$(cat "$restoredPath/restored-path")
    
    # Verify content
    diff -q "${dummyDerivation}/hello.txt" "$ACTUAL_RESTORED_PATH/hello.txt" || exit 1
    echo "NAR bridge test passed!" > $out/result.txt
  '';

in
  testResult