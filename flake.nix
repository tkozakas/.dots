{
  description = "dotfiles via home-manager";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager }:
    let
      username = builtins.getEnv "USER";
      homeDirectory = builtins.getEnv "HOME";
      dotsRoot = homeDirectory + "/.dots";
      workModuleFile = dotsRoot + "-work/home.nix";
      workModules = nixpkgs.lib.optional
        (homeDirectory != "" && builtins.pathExists workModuleFile)
        workModuleFile;

      mkHome = system: home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
        modules = [ ./home.nix ] ++ workModules;
        extraSpecialArgs = {
          inherit username homeDirectory dotsRoot;
        };
      };
    in
    {
      homeConfigurations = {
        linux = mkHome "x86_64-linux";
        darwin = mkHome "aarch64-darwin";
      };
    };
}
