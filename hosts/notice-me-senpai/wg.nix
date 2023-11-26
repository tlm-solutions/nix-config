{ config, ... }: {
  sops.secrets.wg-seckey.owner = config.users.users.systemd-network.name;

  networking.firewall.allowedUDPPorts = [ 51820 ];
  networking.wireguard.enable = true;

  deployment-TLMS.net.wg = {
    prefix4 = 24;
    privateKeyFile = config.sops.secrets.wg-seckey.path;
  };
}
