{ config, pkgs, lib, dotsRoot, username, homeDirectory, ... }:

let
  configsDir = "configs";
  link = path: config.lib.file.mkOutOfStoreSymlink "${dotsRoot}/${configsDir}/${path}";
  toSources = lib.mapAttrs (_: src: { source = link src; });

  cfg = (import ./nix/load-yaml.nix { inherit pkgs lib; }) ./config.yml;

  osKey = if pkgs.stdenv.isLinux then "linux" else "darwin";

  mergeList  = f: (cfg.common.${f} or []) ++ (cfg.${osKey}.${f} or []);
  mergeAttrs = f: (cfg.common.${f} or {}) // (cfg.${osKey}.${f} or {});
in
{
  home.username = username;
  home.homeDirectory = homeDirectory;
  home.stateVersion = "24.11";

  nixpkgs.config.allowUnfree = true;

  home.packages = map
    (p: lib.attrByPath (lib.splitString "." p) (throw "unknown package: ${p}") pkgs)
    (mergeList "packages");

  xdg.configFile = toSources (mergeAttrs "xdgLinks");
  home.file      = toSources (mergeAttrs "homeLinks");

  home.activation.userHooks = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    export PATH="${config.home.profileDirectory}/bin:$PATH"
    ${lib.concatMapStringsSep "\n" (cmd: "$DRY_RUN_CMD ${cmd}") (mergeList "hooks")}
  '';
}
