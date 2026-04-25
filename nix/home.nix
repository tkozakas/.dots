{ config, pkgs, lib, dotsRoot, username, homeDirectory, system, ... }:

let
  isLinux  = lib.hasSuffix "-linux"  system;
  isDarwin = lib.hasSuffix "-darwin" system;
  osKey    = if isLinux then "linux" else "darwin";

  readLayer = root:
    let manifest = root + "/config.json"; in
    if builtins.pathExists manifest
    then { inherit root; cfg = builtins.fromJSON (builtins.readFile manifest); }
    else null;

  base    = readLayer dotsRoot;
  overlay = readLayer (dotsRoot + "-work");
  layers  = lib.filter (l: l != null) [ base overlay ];

  layerList  = layer: f: (layer.cfg.common.${f} or []) ++ (layer.cfg.${osKey}.${f} or []);
  layerAttrs = layer: f: (layer.cfg.common.${f} or {}) // (layer.cfg.${osKey}.${f} or {});

  mergeList  = f: lib.concatMap     (l: layerList  l f) layers;
  mergeAttrs = f: lib.foldl' (acc: l: acc // layerAttrs l f) {} layers;

  mkLinksFor = field:
    lib.foldl' (acc: layer:
      let
        entries = layerAttrs layer field;
        toLink  = path: {
          source = config.lib.file.mkOutOfStoreSymlink
            "${layer.root}/configs/${path}";
        };
      in acc // lib.mapAttrs (_: toLink) entries
    ) {} layers;

  resolvePackage = name:
    lib.attrByPath (lib.splitString "." name) (throw "unknown package: ${name}") pkgs;

  requestedPackages = mergeList "packages";

  ownedByOSModule = [ "hyprland" ];
  basePackages = lib.filter (p: !(builtins.elem p ownedByOSModule)) requestedPackages;
in
{
  imports = [ ]
    ++ lib.optional isLinux  (import ./modules/linux.nix  { inherit requestedPackages; })
    ++ lib.optional isDarwin (import ./modules/darwin.nix { inherit requestedPackages; });

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
    max-jobs = "auto";
    cores = 0;
  };

  home.packages = map resolvePackage basePackages;

  xdg.configFile = mkLinksFor "xdgLinks";
  home.file      = mkLinksFor "homeLinks";

  home.activation.userHooks = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    export PATH="${config.home.profileDirectory}/bin:$PATH"
    ${lib.concatMapStringsSep "\n" (cmd: "$DRY_RUN_CMD ${cmd}") (mergeList "hooks")}
  '';
}
