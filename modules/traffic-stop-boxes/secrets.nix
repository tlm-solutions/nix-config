{ config, pkgs, ... }:
{
  sops.defaultSopsFile = ../../secrets/traffic-stop-box-${toString config.dump-dvb.systemNumber}/secrets.yaml;
  sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

  sops.secrets.wg-seckey = { };
}
