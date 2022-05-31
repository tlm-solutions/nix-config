{ config, pkgs, ... }:
{
  sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

  sops.secrets = {
    wg-seckey = { };
    postgres_password_hash_salt = {
      owner = config.users.users.clicky-bunty-server.name;
    };
    postgres_password = {
      owner = config.users.users.clicky-bunty-server.name;
    };
  };
}
