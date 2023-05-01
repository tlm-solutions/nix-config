{ ... }:
{
  imports = [
    ./configuration.nix
    ./hardware-configuration.nix
    ./uplink.nix
    ./wg.nix
  ];
}
