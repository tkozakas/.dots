{ config, pkgs, lib, dotsRoot, username, homeDirectory, ... }:

let
  link = p: {
    source = config.lib.file.mkOutOfStoreSymlink "${dotsRoot}/${p}";
    force = true;
  };

  linkTargets = map (f: "${config.home.homeDirectory}/${f.target}")
    (lib.filter (f: f.force) (lib.attrValues config.home.file));
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

  home.packages = with pkgs.unstable; [
    sesh
    zip
    unzip
    bitwarden-cli
    nerd-fonts.jetbrains-mono
    git
    git-lfs
    neovim
    ripgrep
    fd
    fzf
    jq
    yq
    gh
    lazygit
    go-task
    zoxide
    lsd
    fastfetch
    tmux
    direnv
    mise
    wget
    k9s
    kubectx
    ast-grep
  ];

  xdg.configFile = {
    nvim = link "configs/nvim";
    alacritty = link "configs/alacritty";
    lazygit = link "configs/lazygit";
    k9s = link "configs/k9s";
    sesh = link "configs/sesh";
  };

  home.file = {
    ".omp/agent" = link "configs/pi";
    ".tmux" = link "configs/tmux";
    ".tmux.conf" = link "configs/tmux/.tmux.conf";
    ".tmux.conf.local" = link "configs/tmux/.tmux.conf.local";
    ".zshrc" = link "configs/zsh/.zshrc";
    ".zshenv" = link "configs/zsh/.zshenv";
    ".zshfn" = link "configs/zsh/.zshfn";
    ".editorconfig" = link "configs/nvim/editorconfig";
    ".gitignore_global" = link "configs/git/.gitignore_global";
    ".gitconfig" = link "configs/git/.gitconfig";
    ".local/bin/git-scripts" = link "configs/git";
  };

  home.activation.cleanupLinkTargets =
    lib.hm.dag.entryBefore [ "checkLinkTargets" ] ''
      ${lib.concatMapStringsSep "\n" (t: ''
        if [ -e "${t}" ] && [ ! -L "${t}" ]; then
          $VERBOSE_ECHO "Removing pre-existing ${t} to allow symlink"
          $DRY_RUN_CMD rm -rf "${t}"
        fi
      '') linkTargets}
    '';

  home.activation.gitExcludes = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    $DRY_RUN_CMD ${pkgs.unstable.git}/bin/git config --global core.excludesFile '~/.gitignore_global'
  '';
}
