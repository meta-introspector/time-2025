{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  
  # Add any other necessary build inputs here
}:

buildNpmPackage rec {
  pname = "lint-staged";
  version = "16.2.3";

  src = fetchTarball {
    url = "https://github.com/meta-introspector/lint-staged/archive/feature/CRQ-016-nixify.tar.gz";
    sha256 = "sha256:0vnd0731vaib2x3q2rkgj2sggqvz1m3s1swgxmqaikg65ilds7pg";
  };

  npmDepsHash = "sha256-TW90pvkKEs5s2nvjkNyf5xQFmM6UueMSm8Ov03I3Nls=";
  dontNpmBuild = true;

  # Add any other build phases or arguments as needed
  # For example, if it needs specific Node.js versions or other tools

  meta = with lib; {
    description = "Run linters against staged git files";
    homepage = "https://github.com/meta-introspector/lint-staged";
    license = licenses.mit;
    platforms = platforms.unix;
    maintainers = [ "jmikedupont2" ];
  };
}