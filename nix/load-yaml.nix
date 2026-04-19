{ pkgs, lib }:
yamlPath:
let
  json = pkgs.runCommand "config.json" { } ''
    ${pkgs.yq-go}/bin/yq -o=json '.' ${yamlPath} > $out
  '';
in
builtins.fromJSON (builtins.readFile json)
