{ config, pkgs, lib, ... }:
let
  shellAliases = {
    ".." = "cd ..";
    "..." = "cd ../..";
    cat = "bat";
    cd = "z";
    ll = "ls -al";
    ls = "eza --color=always --long --git --icons=always";
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
      eza
      fastfetch
      jq
      mise
      nerd-fonts.fira-code
      nerd-fonts.jetbrains-mono
      ripgrep
      ssm-session-manager-plugin
      tldr
      tmux
      tree
      uv
      vim
      wget
    ];

    file = {
#      ".inputrc".text = ''
#        set bell-style visible
#      '';
#      ".config/vim/vimrc".source = ../config/vim/vimrc;
    };
  };

  programs = {
    home-manager = {
      enable = true;
    };

    # Profiles are defined per host in hosts/<name>/aws.nix
    awscli = {
      enable = true;
    };

    bash = {
      enable = true;
      enableCompletion = true;

      inherit shellAliases;
    };

    bat = {
      enable = true;
      config = {
        pager = "less -FR";
        theme = "catppuccin";
      };
      themes = {
        catppuccin = {
          # nix flake prefetch github:catppuccin/bat/<rev>
          src = pkgs.fetchFromGitHub {
            owner = "catppuccin";
            repo = "bat";
            rev = "6810349b28055dce54076712fc05fc68da4b8ec0";
            sha256 = "lJapSgRVENTrbmpVyn+UQabC9fpV1G1e+CdlJ090uvg=";
          };
          file = "themes/Catppuccin Mocha.tmTheme";
        };
      };
    };

    delta = {
      enable = true;
      enableGitIntegration = true;
      options = {
        navigate = true;
        side-by-side = true;
        features = "decorations";
        whitespace-error-style = "22 reverse";

        decorations = {
          commit-decoration-style = "bold yellow box ul";
          file-decoration-style = "none";
          file-style = "bold yellow ul";
        };
      };
    };

    fd = {
      enable = true;
      extraOptions = [
        #"--no-ignore"
        "--strip-cwd-prefix"
        "--absolute-path"
      ];
      hidden = true;
      ignores = [
        ".git/"
        ".bare/"
        "*.bak"
      ];
    };

    fzf = {
      enable = true;
      enableZshIntegration = true;
      colors = {
        fg = "#cbe0f0";
        "fg+" = "#cbe0f0";
        bg = "#011628";
        "bg+" = "#143652";
        hl = "#b388ff";
        "hl+" = "#b388ff";
        info = "#06bce4";
        prompt = "#2cf9ed";
        pointer = "#2cf9ed";
        marker = "#2cf9ed";
        spinner = "#2cf9ed";
        header = "#2cf9ed";
      };
      fileWidget = {
        command = "fd --hidden --strip-cwd-prefix --exclude .git --exclude .bare";
        options = [
          "--preview 'if [ -d {} ]; then eza --tree --color=always {} | head -200; else bat -n --color=always --line-range :500 {}; fi'"
        ];
      };
      changeDirWidget = {
        command = "fd --type=d --hidden --strip-cwd-prefix --exclude .git";
        options = [
          "--preview 'eza --tree --color=always {} | head -200'"
        ];
      };
    };

    git = {
      enable = true;

      ignores = [
        ".DS_Store"
        "*.swp"
      ];

      settings = {
        user = {
          name = "Victor Louie";
          email = "victor@victorlouie.com";
        };

        alias = {
          worktree-clone-bare = "!sh ~/.config/git/scripts/worktree-clone-bare.sh";
          del = "branch -D";
          s = "status";
        };

        core = {
          editor = "vim";
        };

        commit.template = "~/.config/git/commit-template";
        diff.colorMoved = "default";
        merge.conflictstyle = "zdiff3";
        pull.ff = "only";
      };
    };

    granted = {
      enable = true;
      enableZshIntegration = true;
    };

    starship = {
      enable = true;
      enableZshIntegration = true;
      settings = import ../starship/starship.nix;
    };

    zoxide = {
      enable = true;
      enableZshIntegration = true;
    };

    zsh = {
      enable = true;
      enableCompletion = true;

      inherit shellAliases;

      dotDir = "${config.xdg.configHome}/zsh";

      autosuggestion = {
          enable = true;
          highlight = "fg=#171438,bg=white,bold,underline";
          strategy = [ "history" "completion" ];
      };

      syntaxHighlighting = {
          enable = true;
          highlighters = [
              "main"
              "brackets"
              "pattern"
              "cursor"
              "root"
              "line"
          ];
          patterns = {
              "rm -rf *" = "fg=white,bold,bg=red";
          };
          styles = {
              comment = "fg=yellow";
          };
      };

      history = {
          expireDuplicatesFirst = true;
          extended = true;
          ignoreAllDups = false;
          ignoreDups = true;
          ignoreSpace = true;
          save = 10000;
          share = true;
          size = 10000;
      };

      historySubstringSearch = {
          enable = true;
          searchDownKey = [ "^[[B" ];
          searchUpKey = [ "^[[A" ];
      };

      initContent = lib.mkMerge [
        (lib.mkOrder 500 ''
          # Where to look for autoload function definitions
          fpath=(
            ${config.xdg.configHome}/zsh/functions
            "''${fpath[@]}"
          )

          # Autoload all shell functions from all directories in $fpath (following
          # symlinks) that have the executable bit on (the executable bit is not
          # necessary, but gives you an easy way to stop the autoloading of a
          # particular shell function). $fpath should not be empty for this to work.
          for func in $^fpath/*(N-.x:t); autoload $func
        '')

        (lib.mkOrder 1000 ''
          # Completion styling (was appended to completionInit)
          zstyle ':completion:*' menu select

          autoload bashcompinit && bashcompinit
          complete -C aws_completer aws

          # Use fd (https://github.com/sharkdp/fd) for listing path candidates.
          # - The first argument to the function ($1) is the base path to start traversal
          _fzf_compgen_path() {
            fd --hidden --exclude .git . "$1"
          }

          # Use fd to generate the list for directory completion
          _fzf_compgen_dir() {
            fd --type=d --hidden --exclude .git . "$1"
          }

          # Advanced customization of fzf options via _fzf_comprun function
          # - The first argument to the function is the name of the command.
          # - You should make sure to pass the rest of the arguments to fzf.
          _fzf_comprun() {
            local command=$1
            shift

            show_file_or_dir_preview="if [ -d {} ]; then eza --tree --color=always {} | head -200; else bat -n --color=always --line-range :500 {}; fi"

            case "$command" in
              cd)           fzf --preview 'eza --tree --color=always {} | head -200' "$@" ;;
              export|unset) fzf --preview "eval 'echo ''${}'"         "$@" ;;
              ssh)          fzf --preview 'dig {}'                   "$@" ;;
              *)            fzf --preview "$show_file_or_dir_preview" "$@" ;;
            esac
          }

          # Can add comments on commandline
          setopt interactivecomments

          # Move over words with alphanumeric characters as "words"
          #  man zshall - ZLE FUNCTIONS
          autoload -U select-word-style
          select-word-style bash

          # Key Bindings
          bindkey "^[[H"    beginning-of-line  # home
          bindkey "^[[F"    end-of-line        # end
          bindkey "^[[1;3C" forward-word       # alt + right-arrow
          bindkey "^[[1;3D" backward-word      # alt + left-arrow
          bindkey "^[[3~"   delete-char        # delete character under cursor

          # Key Bindings for tmux
          bindkey "\E[1~"    beginning-of-line  # home
          bindkey "\E[4~"    end-of-line        # end
        '')
      ];


    };
  };

}

