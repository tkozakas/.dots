{
  description = "dotfiles via home-manager";

  inputs = {
    nixpkgs.url          = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
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

      mkHome = system:
        let
          isLinux = nixpkgs.lib.hasSuffix "-linux" system;
          unstableOverlay = _final: _prev: {
            unstable = import nixpkgs-unstable {
              inherit system;
              config.allowUnfree = true;
            };
          };
        in home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
            overlays = [ unstableOverlay ]
              ++ nixpkgs.lib.optional isLinux nixgl.overlays.default;
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
