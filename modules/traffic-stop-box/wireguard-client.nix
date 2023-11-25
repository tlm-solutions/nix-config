{ config, lib, registry, ... }:
# pubkey of the box goes to registry/traffic-stop-box/default.nix!
{
  networking.useNetworkd = lib.mkForce true;

  sops.secrets.wg-seckey = {
    owner = config.users.users.systemd-network.name;
  };

  deployment-TLMS.net.wg = {
    addr4 = registry.wgAddr4;
    publicKey = registry.wireguardPublicKey;
    prefix4 = 24;
    privateKeyFile = lib.mkDefault config.sops.secrets.wg-seckey.path;
  };
}
