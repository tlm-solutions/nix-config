{ config, ... }:
{
  sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

  users.groups = {
    postgres-dvbdump = {
      name = "postgres-dvbdump";
      members = [ config.users.users.clicky-bunty-server.name config.users.users.data-accumulator.name ];
    };
    postgres-telegrams = {
      name = "postgres-telegrams";
      members = [ config.users.users.clicky-bunty-server.name config.users.users.data-accumulator.name ];
    };

  };

  sops.secrets = {
    wg-seckey = { };
    postgres_password_hash_salt = {
      owner = config.users.users.clicky-bunty-server.name;
    };
    postgres_password_dvbdump = {
      group = config.users.groups.postgres-dvbdump.name;
      mode = "0440";
    };
    postgres_password_telegrams = {
      group = config.users.groups.postgres-dvbdump.name;
      mode = "0440";
    };

  };
}
