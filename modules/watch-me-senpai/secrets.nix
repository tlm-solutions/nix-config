{ config, ... }:
{
  sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
  sops.secrets = {
    wg-seckey = {
      owner = config.users.users.systemd-network.name;
    };
  };
}
