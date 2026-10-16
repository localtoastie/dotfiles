# Host-specific configuration for thundercracker.
# Layered on top of home/common.nix and home/linux.nix.
{ ... }:

{
  programs.awscli.settings = import ./aws.nix;
}
