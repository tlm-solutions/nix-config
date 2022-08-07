{ pkgs, config, ... }: {

  services.postgresql = {
    enable = true;
    port = 5432;
    package = pkgs.postgresql_14;
    initialScript = pkgs.writeText "dvbdump-initScript" ''
      CREATE DATABASE dvbdump;
      CREATE USER dvbdump;
      GRANT ALL PRIVILEGES ON DATABASE dvbdump TO dvbdump;
      ALTER ROLE dvbdump WITH PASSWORD '$(cat ${config.sops.secrets.postgres_password_dvbdump.path})';

      CREATE DATABASE telegrams;
      CREATE USER telegrams;
      GRANT ALL PRIVILEGES ON DATABASE telegrams TO telegrams;
      ALTER ROLE telegrams WITH PASSWORD '$(cat ${config.sops.secrets.postgres_password_telegrams.path})';

      CREATE USER grafana;
      GRANT CONNECT ON DATABASE telegrams TO grafana;
      GRANT SELECT ON ALL TABLES IN SCHEMA public TO grafana;
      ALTER ROLE grafana WITH PASSWORD '$(cat ${config.sops.secrets.postgres_password_grafana.path})';

      \c telegrams
      create table r09_telegrams (
          id serial8 primary key not null,
          time timestamp not null,
          station UUID not null,
          region integer not null,
          telegram_type int8 not null,
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
        );
      ALTER TABLE r09_telegrams OWNER TO telegrams;
    '';
  };

  systemd.services.dump-csv = {
    path = [ config.services.postgresql.package ];
    serviceConfig = {
      User = "postgres";
    };
    script = ''
      TMPFILE=$(mktemp)

      psql -d telegrams -c "COPY (SELECT id, to_char(time::timestamp at time zone 'UTC', 'YYYY-MM-DD\"T\"HH24:MI:SS') time, station, region, telegram_type, delay, reporting_point, junction, direction, request_status, priority, direction_request, line, run_number, destination_number, train_length, vehicle_number, operator FROM r09_telegrams) TO '$TMPFILE' DELIMITER ',' HEADER CSV;"

      mv $TMPFILE /var/lib/data-accumulator/telegram-dump.csv
    '';
  };

  systemd.timers.dump-csv = {
    partOf = [ "dump-csv.service" ];
    wantedBy = [ "timers.target" ];
    timerConfig.OnCalendar = "hourly";
  };
}
