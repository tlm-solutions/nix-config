{ config, ... }: {
  sops.secrets.wg-seckey.owner = config.users.users.systemd-network.name;

  deployment-TLMS.net.wg = {
    addr4 = "10.13.37.200";
    prefix4 = 24;
    privateKeyFile = config.sops.secrets.wg-seckey.path;
    publicKey = "z2E9TjL9nn0uuLmyQexqddE6g8peB5ENyf0LxpMolD4=";
  };
}
