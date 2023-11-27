{ config, lib, registry, ... }:
# pubkey of the box goes to registry/default.nix!
{
  networking.useNetworkd = lib.mkForce true;

  sops.secrets.wg-seckey = {
    owner = config.users.users.systemd-network.name;
  };

  deployment-TLMS.net.wg = {
    prefix4 = 24;
    privateKeyFile = lib.mkDefault config.sops.secrets.wg-seckey.path;
  };
}
