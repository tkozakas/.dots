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
          force = true;
        };
      in acc // lib.mapAttrs (_: toLink) entries
    ) {} layers;

  # Try resolving a dotted package path (e.g. "unstable.neovim").
  # Returns the package on success, null + warning on failure.
  resolvePackage = name:
    let
      tried = builtins.tryEval (
        lib.attrByPath (lib.splitString "." name) (throw "missing") pkgs
      );
    in
    if tried.success
    then tried.value
    else lib.warn "skipping '${name}': not found in nixpkgs" null;

  requestedPackages = mergeList "packages";

  # hyprland needs nixGL wrapping on non-NixOS Linux; handle it specially.
  needsHyprland   = isLinux && builtins.elem "hyprland" requestedPackages;
  basePackageNames = lib.filter (p: p != "hyprland") requestedPackages;

  hyprlandPackages =
    let
      nixGL    = pkgs.nixgl.nixGLIntel;
      nixGLBin = "${nixGL}/bin/nixGLIntel";
      mkLauncher = name: pkgs.writeShellScript name ''
        exec ${nixGLBin} ${pkgs.hyprland}/bin/${name} "$@"
      '';
      wrapped = pkgs.symlinkJoin {
        name = "hyprland-nixgl-${pkgs.hyprland.version}";
        paths = [ pkgs.hyprland ];
        postBuild = ''
          rm -f $out/bin/Hyprland $out/bin/hyprland
          install -m755 ${mkLauncher "Hyprland"} $out/bin/Hyprland
          install -m755 ${mkLauncher "hyprland"} $out/bin/hyprland
        '';
      };
    in [ nixGL wrapped ];

  resolvedPackages =
    lib.filter (p: p != null) (map resolvePackage basePackageNames)
    ++ lib.optionals needsHyprland hyprlandPackages;
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
    max-jobs = "auto";
    cores = 0;
  };

  home.packages = resolvedPackages;

  xdg.configFile = mkLinksFor "xdgLinks";
  home.file      = mkLinksFor "homeLinks";

  home.activation.userHooks = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    export PATH="${config.home.profileDirectory}/bin:$PATH"
    ${lib.concatMapStringsSep "\n" (cmd: "$DRY_RUN_CMD ${cmd}") (mergeList "hooks")}
  '';
}
