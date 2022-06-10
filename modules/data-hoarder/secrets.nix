{ config, pkgs, ... }:
{
  sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

  users.groups = {
    postgres-dvbdump = {
      name = "postgres-dvbdump";
      members = [ config.users.users.clicky-bunty-server.name config.users.users.data-accumulator.name ];
    };
  };

  sops.secrets = {
    wg-seckey = { };
    postgres_password_hash_salt = {
      owner = config.users.users.clicky-bunty-server.name;
    };
    postgres_password = {
      group = config.users.groups.postgres-dvbdump.name;
      mode = "0440";
    };
  };
}
