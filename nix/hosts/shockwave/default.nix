# Host-specific configuration for shockwave (work machine).
# Layered on top of home/common.nix and home/linux.nix.
{ config, pkgs, lib, ... }:

{
  home.packages = with pkgs; [
    # Work-only packages go here
  ];

  # Use the work email only inside work repos; everything else keeps the
  # personal email from home/common.nix
  programs.git.includes = map (dir: {
    condition = "gitdir:${dir}";
    contents.user.email = "victor.louie@withreach.com";
  }) [
    "~/git/withreach/"
    "~/git/victorlouie-reach/"
  ];

  # Merged with the aliases from home/common.nix
  programs.zsh.shellAliases = {
    c = "shockwave-hello";
  };

  # AWS profiles for this host only
  programs.awscli.settings = import ./aws.nix;

  # Work-only zsh functions, linked to ~/.config/zsh/functions-shockwave
  xdg.configFile."zsh/functions-shockwave" = {
    source = ./zsh-functions;
    recursive = true;
  };

  # Prepend to fpath before common.nix's autoload loop (mkOrder 500) runs
  programs.zsh.initContent = lib.mkOrder 490 ''
    fpath=(
      ${config.xdg.configHome}/zsh/functions-shockwave
      "''${fpath[@]}"
    )
  '';
}
