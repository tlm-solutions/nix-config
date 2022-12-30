{ config, self, ... }:
{
  sops.defaultSopsFile = self + /secrets/traffic-stop-box-${toString config.deployment-TLMS.systemNumber}/secrets.yaml;
  sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

  sops.secrets.telegram-decoder-token.owner = config.users.users.telegram-decoder.name;
}
