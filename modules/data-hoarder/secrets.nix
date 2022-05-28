{ config, pkgs, ... }:
{
  sops.defaultSopsFile = ../../secrets/data-hoarder/secrets.yaml;
  sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

  sops.secrets = {
    wg-seckey-staging = { };
    wg-seckey = { };
    postgres_password_hash_salt = {
      owner = config.users.users.postgres.name;
    };
  };
}
