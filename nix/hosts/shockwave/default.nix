# Host-specific configuration for shockwave (work machine).
# Layered on top of home/common.nix, home/linux.nix and home/redhat.nix.
{ config, pkgs, lib, ... }:

let
  # Public half of this host's key in 1Password (the private key stays there)
  sshKey = lib.trim (builtins.readFile ./ssh-key.pub);
in
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

  # Keys the 1Password SSH agent offers on this machine
  xdg.configFile."1Password/ssh/agent.toml".text = ''
    [[ssh-keys]]
    vault = "Employee"
  '';

  # ssh uses the .pub file to pick the matching key from the agent
  home.file.".ssh/shockwave.pub".source = ./ssh-key.pub;

  programs.ssh.settings."github.com" = {
    IdentityFile = "~/.ssh/shockwave.pub";
    IdentitiesOnly = true;
  };

  # Sign commits and tags with the same key via 1Password. Both emails are
  # trusted because personal repos on this machine still use the personal one.
  programs.git.signing = {
    format = "ssh";
    key = sshKey;
    signByDefault = true;
    signer = "${pkgs._1password-gui}/bin/op-ssh-sign";
    allowedSigners = ''
      victor.louie@withreach.com namespaces="git" ${sshKey}
      victor@victorlouie.com namespaces="git" ${sshKey}
    '';
  };

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
