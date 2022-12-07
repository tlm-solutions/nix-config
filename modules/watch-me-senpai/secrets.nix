{ config, ... }:
let
  clicky-bunty-user = config.dump-dvb.clickyBuntyServer.user;
  data-accumulator-user = config.dump-dvb.dataAccumulator.user;
  trekkie-user = config.dump-dvb.trekkie.user;
in
{
  sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

  users.groups = {
    postgres-dvbdump = {
      name = "postgres-dvbdump";
      members = [ clicky-bunty-user data-accumulator-user trekkie-user "postgres" ];
    };

    password-salt = {
      name = "password-salt";
      members = [ clicky-bunty-user trekkie-user "postgres" ];
    };

    #TODO: remove this the two databases got merged
    postgres-telegrams = {
      name = "postgres-telegrams";
      members = [ clicky-bunty-user data-accumulator-user "postgres" ];
    };

  };

  sops.secrets = {
    wg-seckey = {
      owner = config.users.users.systemd-network.name;
    };
  };
}
