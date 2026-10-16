# Red Hat family (RHEL/Rocky/Alma/Fedora) configuration
{ pkgs, ... }:

{
  home.packages = with pkgs; [
    podman
    podman-compose
  ];
}
