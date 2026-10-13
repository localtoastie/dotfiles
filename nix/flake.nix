{
  description = "Home Manager configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ...  }:
    let
      mkHome = { system, username, extraModules ? [] }:
        home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
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
                configFile."zsh/functions" = {
                  source = ./zsh-functions;
                  recursive = true;
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
          extraModules = [ ./home/linux.nix ];
        };

#        "victor@skywarp" = mkHome {
#           system = "aarch64-darwin";
#           username = "victor";
#           extraModules = [ ./home/darwin.nix ];
#        };
      };
    };
}

