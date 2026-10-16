# Linux-only configuration (non-NixOS hosts, so GUI apps go through nixGL)
{ config, pkgs, inputs, ... }:

{
  home.packages = with pkgs; [
    strace
    _1password-gui
    brave
    google-chrome
    obsidian
    slack
  ];

  targets.genericLinux.nixGL = {
    packages = inputs.nixGL.packages;
    defaultWrapper = "mesa";
  };

  programs.ghostty = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    package = config.lib.nixGL.wrap pkgs.ghostty;
  };
}
