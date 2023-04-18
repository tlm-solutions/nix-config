{ config, ... }:
let
  datacare-user = config.TLMS.datacare.user;
  data-accumulator-user = config.TLMS.dataAccumulator.user;
  trekkie-user = config.TLMS.trekkie.user;
  chemo-user = config.TLMS.chemo.user;
in
{
  sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

  users.groups = {
    postgres-tlms = {
      name = "postgres-tlms";
      members = [ datacare-user data-accumulator-user trekkie-user chemo-user "postgres" ];
    };

    password-salt = {
      name = "password-salt";
      members = [ datacare-user trekkie-user "postgres" ];
    };

    #TODO: remove this the two databases got merged
    postgres-telegrams = {
      name = "postgres-telegrams";
      members = [ datacare-user data-accumulator-user "postgres" ];
    };

  };

  sops.secrets = {
    wg-seckey = {
      owner = config.users.users.systemd-network.name;
    };
    postgres_password_hash_salt = {
      group = config.users.groups.password-salt.name;
      mode = "0440";
    };
    postgres_password = {
      group = config.users.groups.postgres-tlms.name;
      mode = "0440";
    };
    postgres_password_grafana = {
      group = config.users.groups.postgres-tlms.name;
      mode = "0440";
    };

  };
}
