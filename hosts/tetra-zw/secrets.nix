{ config, self, registry, ... }:
{
  sops.defaultSopsFile = self + /secrets/${registry.hostName}/secrets.yaml;
  sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
}
