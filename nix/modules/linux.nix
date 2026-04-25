{ requestedPackages }:

{ ... }: {
  imports = [
    (import ./hyprland-nixgl.nix { inherit requestedPackages; })
  ];
}
