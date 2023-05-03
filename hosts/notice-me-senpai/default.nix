{ ... }:
{
  imports = [
    ./configuration.nix
    ./hardware-configuration.nix
    ./grafana.nix
    ./uplink.nix
    ./wg.nix
  ];
}
