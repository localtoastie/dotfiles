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
    settings = {
      theme = "Catppuccin Mocha";
      font-family = "JetBrainsMono Nerd Font";
      font-size = 12;
      copy-on-select = "clipboard";
      mouse-hide-while-typing = "true";
      keybind = [
        "ctrl+s>r=reload_config"
        "ctrl+s>x=close_surface"
        "ctrl+s>n=new_window"
        # tabs
        "ctrl+s>c=new_tab"
        "ctrl+s>shift+l=next_tab"
        "ctrl+s>shift+h=previous_tab"
        "ctrl+s>comma=move_tab:-1"
        "ctrl+s>period=move_tab:1"
        # quick tab switch
        "ctrl+s>1=goto_tab:1"
        "ctrl+s>2=goto_tab:2"
        "ctrl+s>3=goto_tab:3"
        "ctrl+s>4=goto_tab:4"
        "ctrl+s>5=goto_tab:5"
        "ctrl+s>6=goto_tab:6"
        "ctrl+s>7=goto_tab:7"
        "ctrl+s>8=goto_tab:8"
        "ctrl+s>9=goto_tab:9"
        # split
        "ctrl+s>\\=new_split:right"
        "ctrl+s>-=new_split:down"
        "ctrl+s>j=goto_split:bottom"
        "ctrl+s>k=goto_split:top"
        "ctrl+s>h=goto_split:left"
        "ctrl+s>l=goto_split:right"
        "ctrl+s>z=toggle_split_zoom"
        "ctrl+s>e=equalize_splits"
      ];
    };
  };
}
