{ lib, pkgs, config, inputs, self, registry, ... }: {

  services.postgresql = {
    settings.port = registry.postgres.port;
    enable = true;
    enableTCPIP = true;
    authentication =
      let
        senpai-ip =
          self.unevaluatedNixosConfigurations.notice-me-senpai.specialArgs.registry.wgAddr4;
      in
      pkgs.lib.mkOverride 10 ''
        local	all	all	trust
        host	all	all	127.0.0.1/32	trust
        host	all	all	::1/128	trust
        host	tlms	grafana	${senpai-ip}/32	scram-sha-256
      '';
    package = pkgs.postgresql_14;
    ensureDatabases = [ "tlms" ];
    ensureUsers = [
      {
        name = "tlms";
        ensureDBOwnership = true;
      }
      {
        name = "grafana";
      }
    ];
  };

  environment.systemPackages =
    [ inputs.tlms-rs.packages.x86_64-linux.run-migration-based ];

  systemd.services.postgresql = {
    unitConfig = { TimeoutStartSec = 3000; };
    serviceConfig = { TimeoutSec = lib.mkForce 3000; };
    postStart = lib.mkAfter ''
      # set pw for the users
      $PSQL -c "ALTER ROLE tlms WITH PASSWORD '$(cat ${config.sops.secrets.postgres_password.path})';"
      $PSQL -c "ALTER ROLE grafana WITH PASSWORD '$(cat ${config.sops.secrets.postgres_password_grafana.path})';"

      export DATABASE_URL=postgres:///tlms
      ${inputs.tlms-rs.packages.x86_64-linux.run-migration-based}/bin/run-migration

      # fixup permissions
      # tlms is practically root, we need to FIXME something about it
      $PSQL -c "GRANT ALL ON DATABASE tlms TO tlms;"
      $PSQL -d tlms -c "GRANT ALL ON ALL TABLES IN SCHEMA public TO tlms;"
      $PSQL -d tlms -c "GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO tlms;"

      # Get graphana to SELECT from tables that might be interesting for it
      $PSQL -c "GRANT CONNECT ON DATABASE tlms TO grafana;"
      $PSQL -d tlms -c "GRANT SELECT ON r09_telegrams, r09_transmission_locations_raw, raw_telegrams, gps_points, trekkie_runs, regions, stations TO grafana;"

      unset DATABASE_URL
    '';
  };

  systemd.services.dump-csv = {
    path = [ config.services.postgresql.package ];
    serviceConfig = { User = "postgres"; };
    script = ''
      TMPFILE=$(mktemp)
      OUT_FOLDER=/var/lib/pub-files/postgres-dumps/$(date -d"$(date) - 1 day" +"%Y-%m")
      CSV_FILENAME=$(date -d"$(date) - 1 day" +"%Y-%m-%d").csv

      psql -d tlms -c "COPY (SELECT id, to_char(time::timestamp at time zone 'UTC', 'YYYY-MM-DD\"T\"HH24:MI:SS') time, station, r09_type, delay, reporting_point, junction, direction, request_status, priority, direction_request, line, run_number, destination_number, train_length, vehicle_number, operator, region FROM r09_telegrams WHERE time > now() - interval '24 hours' ORDER by time ASC) TO STDOUT DELIMITER ',' HEADER CSV;" > $TMPFILE

      mkdir -p $OUT_FOLDER
      chmod a+xr $OUT_FOLDER
      
      echo "Copying $TMPFILE to $OUT_FOLDER/$CSV_FILENAME"
      cat $TMPFILE | wc -l

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
