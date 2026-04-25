{ requestedPackages }:

{ pkgs, lib, ... }:

let
  enabled = builtins.elem "hyprland" requestedPackages;

  nixGL    = pkgs.nixgl.nixGLIntel;
  nixGLBin = "${nixGL}/bin/nixGLIntel";

  mkNixGLLauncher = name: pkgs.writeShellScript name ''
    exec ${nixGLBin} ${pkgs.hyprland}/bin/${name} "$@"
  '';

  hyprlandWrapped = pkgs.symlinkJoin {
    name = "hyprland-nixgl-${pkgs.hyprland.version}";
    paths = [ pkgs.hyprland ];
    postBuild = ''
      rm -f $out/bin/Hyprland $out/bin/hyprland
      install -m755 ${mkNixGLLauncher "Hyprland"} $out/bin/Hyprland
      install -m755 ${mkNixGLLauncher "hyprland"} $out/bin/hyprland
    '';
  };
in
lib.mkIf enabled {
  home.packages = [
    nixGL
    hyprlandWrapped
  ];
}
