{ config, pkgs, lib, dotsRoot, username, homeDirectory, ... }:

let
  configsDir = "configs";
  link = path: config.lib.file.mkOutOfStoreSymlink "${dotsRoot}/${configsDir}/${path}";
  toSources = lib.mapAttrs (_: src: { source = link src; });

  cfg = (import ./load-yaml.nix { inherit pkgs lib; }) ../config.yml;

  osKey = if pkgs.stdenv.isLinux then "linux" else "darwin";

  mergeList  = f: (cfg.common.${f} or []) ++ (cfg.${osKey}.${f} or []);
  mergeAttrs = f: (cfg.common.${f} or {}) // (cfg.${osKey}.${f} or {});
in
{
  home.username = username;
  home.homeDirectory = homeDirectory;
  home.stateVersion = "25.05";
  home.enableNixpkgsReleaseCheck = false;

  nixpkgs.config.allowUnfree = true;

  programs.home-manager.enable = true;

  nix.package = pkgs.nix;
  nix.settings = {
    warn-dirty = false;
    experimental-features = [ "nix-command" "flakes" ];
  };

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
