{ config, pkgs, ... }:
{
  sops.defaultSopsFile = ../../secrets/traffic-stop-box-${toString config.dvb-dump.systemNumber}/secrets.yaml;
  sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

  sops.secrets.wg-seckey = { };
}
