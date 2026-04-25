{
  description = "dotfiles via home-manager";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixgl = {
      url = "github:nix-community/nixGL";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, nixgl }:
    let
      username      = builtins.getEnv "USER";
      homeDirectory = builtins.getEnv "HOME";
      dotsRoot      = homeDirectory + "/.dots";

      mkHome = system: home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
          overlays = [
            nixgl.overlays.default
            (final: _prev: {
              unstable = import nixpkgs-unstable {
                inherit system;
                config.allowUnfree = true;
              };
            })
          ];
        };
        modules = [ ./nix/home.nix ];
        extraSpecialArgs = {
          inherit username homeDirectory dotsRoot system;
        };
      };
    in
    {
      homeConfigurations = {
        linux  = mkHome "x86_64-linux";
        darwin = mkHome "aarch64-darwin";
      };

      packages.x86_64-linux.home-manager   = home-manager.packages.x86_64-linux.default;
      packages.aarch64-darwin.home-manager = home-manager.packages.aarch64-darwin.default;

      formatter.x86_64-linux   = nixpkgs.legacyPackages.x86_64-linux.nixpkgs-fmt;
      formatter.aarch64-darwin = nixpkgs.legacyPackages.aarch64-darwin.nixpkgs-fmt;
    };
}
