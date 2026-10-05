{ config, pkgs, lib, dotsRoot, ... }:

let
  link = p: {
    source = config.lib.file.mkOutOfStoreSymlink "${dotsRoot}/${p}";
    force = true;
  };

  hyprlandPackages =
    let
      nixGL = pkgs.nixgl.nixGLIntel;
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
    in
    [ nixGL wrapped ];
in
{
  home.packages = (with pkgs; [
    hyprlock
    hyprpaper
    hypridle
    hyprutils
    waybar
    rofi
    swww
    slurp
    grim
    wl-clipboard
  ]) ++ (with pkgs.unstable; [
    docker
    docker-compose
    firefox
    python3
    noto-fonts
    noto-fonts-color-emoji
    noto-fonts-cjk-sans
    nautilus
    discord
    spotify
    jetbrains-toolbox
    alacritty
  ]) ++ hyprlandPackages;

  xdg.configFile = {
    hypr = link "configs/hypr";
    wireplumber = link "configs/wireplumber";
    "Code/User/settings.json" = link "configs/vscode/settings.json";
  };
}
