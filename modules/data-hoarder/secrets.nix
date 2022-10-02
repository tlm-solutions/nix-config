{ config, ... }:
let
  clicky-bunty-user = config.dump-dvb.clickyBuntyServer.user;
  data-accumulator-user = config.dump-dvb.dataAccumulator.user;
in
{
  sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

  users.groups = {
    postgres-dvbdump = {
      name = "postgres-dvbdump";
      members = [ clicky-bunty-user data-accumulator-user "postgres" ];
    };
    postgres-telegrams = {
      name = "postgres-telegrams";
      members = [ clicky-bunty-user data-accumulator-user "postgres" ];
    };

  };

  sops.secrets = {
    wg-seckey = {
      owner = config.users.users.systemd-network.name;
    };
    postgres_password_hash_salt = {
      owner = clicky-bunty-user;
    };
    postgres_password = {
      group = config.users.groups.postgres-dvbdump.name;
      mode = "0440";
    };
    postgres_password_grafana = {
      group = config.users.groups.postgres-dvbdump.name;
      mode = "0440";
    };

  };
}
