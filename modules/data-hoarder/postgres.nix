{ lib, pkgs, config, dump-dvb, ... }: {

  services.postgresql = {
    enable = true;
    port = 5432;
    package = pkgs.postgresql_14;
    ensureDatabases = [ "dvbdump" ];
    ensureUsers = [
      {
        name = "grafana";
      }
      {
        name = "dvbdump";
        ensurePermissions = {
          "DATABASE dvbdump" = "ALL PRIVILEGES";
        };
      }
    ];
  };

  environment.systemPackages = [ dump-dvb.packages.x86_64-linux.run-database-migration ];

  systemd.services.postgresql.postStart = lib.mkAfter ''
    # TODO: make shure grafana can't read tokens...
    $PSQL -c "GRANT CONNECT ON DATABASE dvbdump TO grafana;"
    $PSQL -c "GRANT SELECT ON ALL TABLES IN SCHEMA public TO grafana";

    $PSQL -c "ALTER ROLE dvbdump WITH PASSWORD '$(cat ${config.sops.secrets.postgres_password.path})';" 
    $PSQL -c "ALTER ROLE grafana WITH PASSWORD '$(cat ${config.sops.secrets.postgres_password_grafana.path})';" 

    export DATABASE_URL=postgres://dvbdump:$(cat ${config.sops.secrets.postgres_password.path})@localhost/dvbdump
    ${dump-dvb.packages.x86_64-linux.run-database-migration}/bin/run-migration
    unset DATABASE_URL
  '';

  systemd.services.dump-csv = {
    path = [ config.services.postgresql.package ];
    serviceConfig = {
      User = "postgres";
    };
    script = ''
      TMPFILE=$(mktemp)

      psql -d dvbdump -c "COPY (SELECT id, to_char(time::timestamp at time zone 'UTC', 'YYYY-MM-DD\"T\"HH24:MI:SS') time, station, telegram_type, delay, reporting_point, junction, direction, request_status, priority, direction_request, line, run_number, destination_number, train_length, vehicle_number, operator FROM r09_telegrams) TO '$TMPFILE' DELIMITER ',' HEADER CSV;"

      cp $TMPFILE /var/lib/data-accumulator/telegram-dump.csv
      rm -f $TMPFILE

      chmod a+r /var/lib/data-accumulator/telegram-dump.csv
    '';
  };

  systemd.timers.dump-csv = {
    partOf = [ "dump-csv.service" ];
    wantedBy = [ "timers.target" ];
    timerConfig.OnCalendar = "hourly";
  };
}
