# Host-specific configuration for thundercracker.
# Layered on top of home/common.nix, home/linux.nix and home/redhat.nix.
{ pkgs, lib, ... }:

let
  # Public half of this host's key in 1Password (the private key stays there)
  sshKey = lib.trim (builtins.readFile ./ssh-key.pub);
in
{
  # Keys the 1Password SSH agent offers on this machine
  xdg.configFile."1Password/ssh/agent.toml".text = ''
    [[ssh-keys]]
    vault = "Dev"
  '';

  # ssh uses the .pub file to pick the matching key from the agent
  home.file.".ssh/thundercracker.pub".source = ./ssh-key.pub;

  programs.ssh.settings."github.com" = {
    IdentityFile = "~/.ssh/thundercracker.pub";
    IdentitiesOnly = true;
  };

  # Sign commits and tags with the same key via 1Password
  programs.git.signing = {
    format = "ssh";
    key = sshKey;
    signByDefault = true;
    signer = "${pkgs._1password-gui}/bin/op-ssh-sign";
    allowedSigners = "victor@victorlouie.com namespaces=\"git\" ${sshKey}";
  };
}
