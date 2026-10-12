{ config, pkgs, ... }:
let
  shellAliases = {
    ".." = "cd ..";
    "..." = "cd ../..";
    cat = "bat";
    cd = "z";
    vi = "vim";
  };
in {
  fonts = {
    fontconfig = {
      enable = true;
    };
  };

  home = { 
    stateVersion = "26.05";

    packages = with pkgs; [
      _1password-cli
      awscli2
      bash-completion
      bat
      eza
      fastfetch
      fd
      fzf
      granted
      jq
      mise
      nerd-fonts.fira-code
      podman
      podman-compose
      ripgrep
      ssm-session-manager-plugin
      starship
      strace
      tmux
      tree
      uv
      vim
      wget
      zoxide
      zsh-syntax-highlighting
      zsh-history-substring-search
      _1password-gui
      brave
      google-chrome
      obsidian
    ];

    file = {
#      ".inputrc".text = ''
#        set bell-style visible
#      '';
#      ".config/git/ignore".text = ''
#        .DS_Store
#      '';
#      ".config/git/commit-template".source = ../config/git/commit-template;
#      ".config/git/scripts".source = ../config/git/scripts;
#      ".config/vim/vimrc".source = ../config/vim/vimrc;
#      ".config/zsh/functions".source = ../config/zsh/functions;
    };
  };

  programs = {
    home-manager = {
      enable = true;
    };

    awscli = {
      enable = true;
      settings = import ./aws/config.nix;
    };

    bash = {
      enable = true;
    };

    git = {
      enable = true;
      settings.user = {
        name = "Victor Louie";
        email = "victor@victorlouie.com";
      };
    };

    zsh = {
      enable = true;
    };
  };

}

