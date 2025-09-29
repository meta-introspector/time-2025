
{ lib, buildNpmPackage, nodejs, ... }:

buildNpmPackage rec {
  pname = "lint-staged";
  version = "15.2.2"; # This should match the version of the vendored lint-staged

  src = src + /nix/vendor/lint-staged; # Path to the vendored submodule

  buildInputs = [ nodejs ];

  # npm install flags
  npmBuildFlags = [ "--ignore-scripts" ]; # Ignore postinstall scripts if they cause issues

  meta = with lib; {
    description = "Run linters against staged git files";
    homepage = "https://github.com/lint-staged/lint-staged";
    license = licenses.MIT;
    maintainers = with maintainers; [ ]; # Add maintainers if known
  };
}
