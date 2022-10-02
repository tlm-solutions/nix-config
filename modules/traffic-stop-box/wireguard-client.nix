{ config, lib, ... }:
# pubkey of the box goes to hosts/traffic-stop-box/${id}.nix!
{
  networking.useNetworkd = lib.mkForce true;

  sops.secrets.wg-seckey = {
      owner = config.users.users.systemd-network.name;
  };
  deployment-dvb.net.wg = {
    addr4 = lib.mkDefault "10.13.37.${toString (config.deployment-dvb.systemNumber + 100)}";
    prefix4 = 24;
    privateKeyFile = lib.mkDefault config.sops.secrets.wg-seckey.path;
  };
}
