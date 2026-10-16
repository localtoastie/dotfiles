{
  description = "Home Manager configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixGL = {
      url = "github:nix-community/nixGL";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager,  ...  } @ inputs:
    let
      mkHome = { system, username, extraModules ? [] }:
        home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };

          extraSpecialArgs = { 
            inherit inputs;
          };

          modules = [ ./home/common.nix ] ++ extraModules ++ [
            {
              home.username = username;
              home.homeDirectory =
                if builtins.match ".*darwin" system != null
                then "/Users/${username}"
                else "/home/${username}";
              home.backupFileExtension = "hm-backup";
              xdg = {
                enable = true;
                configFile = {
                  "zsh/functions" = {
                    source = ./zsh-functions;
                    recursive = true;
                  };
                  "git/commit-template" = {
                    source = ./git/commit-template;
                  };
                  "git/scripts/worktree-clone-bare.sh" = {
                    source = ./git/scripts/worktree-clone-bare.sh;
                    executable = true;
                  };
                };
              };
            }
          ];
        };
    in
    {
      homeConfigurations = {
        "victor@thundercracker" = mkHome {
          system = "x86_64-linux";
          username = "victor";
          extraModules = [ ./home/linux.nix ./home/redhat.nix ./hosts/thundercracker ];
        };

        "victor@shockwave" = mkHome {
          system = "x86_64-linux";
          username = "victor";
          extraModules = [ ./home/linux.nix ./home/redhat.nix ./hosts/shockwave ];
        };

#        "victor@skywarp" = mkHome {
#           system = "aarch64-darwin";
#           username = "victor";
#           extraModules = [ ./home/darwin.nix ];
#        };
      };
    };
}

