{ pkgs, config, lib, ... }: {

  services.postgresql = {
    enable = true;
    port = 5432;
    package = pkgs.postgresql_14;
    ensureUsers = [
      {
        name = "dvbdump";
        ensurePermissions = {
          "DATABASE dvbdump" = "ALL PRIVILEGES";
        };
      }
      {
        name = "telegrams";
        ensurePermissions = {
          "DATABASE telegrams" = "ALL PRIVILEGES";
        };
      }

    ];
    ensureDatabases = [
      "dvbdump"
      "telegrams"
    ];
  };
  systemd.services."pg-dvbdump-setup" = {
    description = "prepare dvbdump postgres database";
    wantedBy = [ "multi-user.target" ];
    after = [ "networking.target" "postgresql.service" ];
    serviceConfig.Type = "oneshot";

    path = [ pkgs.sudo config.services.postgresql.package ];
    script = ''
      sudo -u ${config.services.postgresql.superUser} psql -c "ALTER ROLE dvbdump WITH PASSWORD '$(cat ${config.sops.secrets.postgres_password_dvbdump.path})'"
      sudo -u ${config.services.postgresql.superUser} psql -c "ALTER ROLE telegrams WITH PASSWORD '$(cat ${config.sops.secrets.postgres_password_telegrams.path})'"

      sudo -u ${config.services.postgresql.superUser} psql --dbname telegrams -c "create table r09_telegrams (
          id serial8 primary key not null,
          time timestamp not null,
          station UUID not null,
          region int8 not null,
          type int8 not null,
          delay int,
          reporting_point int not null,
          junction int not null,
          direction int2 not null,
          request_status int2 not null,
          priority int2,
          direction_request int2,
          line int,
          run_number int,
          destination_number int,
          train_length int2,
          vehicle_number int,
          operator int2
        );"
    '';
  };
}
