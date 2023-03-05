{ lib, pkgs, config, inputs, ... }: {

  services.postgresql = {
    enable = true;
    port = 5432;
    package = pkgs.postgresql_14;
    ensureDatabases = [ "tlms" ];
    ensureUsers = [
      {
        name = "grafana";
      }
      {
        name = "tlms";
        ensurePermissions = {
          "DATABASE tlms" = "ALL PRIVILEGES";
          "ALL TABLES IN SCHEMA public" = "ALL";
        };
      }
    ];
  };

  environment.systemPackages = [ inputs.tlms-rs.packages.x86_64-linux.run-migration ];

  systemd.services.postgresql = {
    unitConfig = {
      TimeoutStartSec=3000;
    };
    serviceConfig = {
      TimeoutSec = lib.mkForce 3000;
    };
    postStart = lib.mkAfter ''
      # TODO: make shure grafana can't read tokens...
      $PSQL -c "GRANT CONNECT ON DATABASE tlms TO grafana;"
      $PSQL -c "GRANT SELECT ON ALL TABLES IN SCHEMA public TO grafana";

      $PSQL -c "ALTER ROLE tlms WITH PASSWORD '$(cat ${config.sops.secrets.postgres_password.path})';"
      $PSQL -c "ALTER ROLE grafana WITH PASSWORD '$(cat ${config.sops.secrets.postgres_password_grafana.path})';"

      export DATABASE_URL=postgres:///tlms
      ${inputs.tlms-rs.packages.x86_64-linux.run-migration}/bin/run-migration

      # fixup permissions
      $PSQL -c "GRANT ALL ON DATABASE tlms TO dvbdump;"
      $PSQL -d tlms -c "GRANT ALL ON ALL TABLES IN SCHEMA public TO dvbdump;"
      $PSQL -d tlms -c "GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO dvbdump;"

      unset DATABASE_URL
    '';
  };

  systemd.services.dump-csv = {
    path = [ config.services.postgresql.package ];
    serviceConfig = {
      User = "postgres";
    };
    script = ''
      TMPFILE=$(mktemp)
      OUT_FOLDER=/var/lib/pub-files/postgres-dumps/$(date -d"$(date) - 1 day" +"%Y-%m")
      CSV_FILENAME=$(date -d"$(date) - 1 day" +"%Y-%m-%d").csv

      psql -d tlms -c "COPY (SELECT id, to_char(time::timestamp at time zone 'UTC', 'YYYY-MM-DD"T"HH24:MI:SS') time, station, telegram_type, delay, reporting_point, junction, direction, request_status, priority, direction_request, line, run_number, destination_number, train_length, vehicle_number, operator, region FROM r09_telegrams WHERE time::date = current_date - 1 ORDER by time ASC) TO '$TMPFILE' DELIMITER ',' HEADER CSV;"

      mkdir -p $OUT_FOLDER
      chmod a+xr $OUT_FOLDER

      cp $TMPFILE $OUT_FOLDER/$CSV_FILENAME
      chmod a+r $OUT_FOLDER/$CSV_FILENAME

      rm -f $TMPFILE
    '';
  };

  systemd.timers.dump-csv = {
    partOf = [ "dump-csv.service" ];
    wantedBy = [ "timers.target" ];
    timerConfig.OnCalendar = "*-*-* 03:11:19";
  };
}
