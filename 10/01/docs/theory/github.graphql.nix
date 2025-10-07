{ lib, pkgs, builtins, self, ... }:

(self.lib.github_graphql_modules.github_graphql_main { inherit lib pkgs builtins; }).buildGraphQLQuery