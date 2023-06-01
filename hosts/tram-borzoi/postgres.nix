{ lib, pkgs, config, inputs, self, ... }: {

  sops.secrets.postgres-borzoi-pw = {
    owner = config.users.users.postgres.name;
    group = config.users.groups.borzoi.name;
    mode = "0440";
  };
  sops.secrets.postgres-borzoi-grafana-pw = {
    owner = config.users.users.postgres.name;
  };
  services.postgresql = {
    enable = true;
    enableTCPIP = true;
    port = 5432;
    authentication =
      let
        senpai-ip = self.nixosConfigurations.notice-me-senpai.config.deployment-TLMS.net.wg.addr4;
        # TODO: fixme
        uranus-ip = "10.13.37.9";
      in
      pkgs.lib.mkOverride 10 ''
        local	all	all	trust
        host	all	all	127.0.0.1/32	trust
        host	all	all	::1/128	trust
        host	tlms	grafana	${senpai-ip}/32	scram-sha-256
        host	borzoi	grafana	${senpai-ip}/32	scram-sha-256
        host  borzoi  grafana ${uranus-ip}/32 scram-sha-256
      '';
    package = pkgs.postgresql_14;
    ensureDatabases = [ "borzoi" ];
    ensureUsers = [
      {
        name = "grafana";
      }
      {
        name = "borzoi";
        ensurePermissions = {
          "DATABASE borzoi" = "ALL PRIVILEGES";
          "ALL TABLES IN SCHEMA public" = "ALL";
        };
      }
    ];
  };

  systemd.services.postgresql = {
    unitConfig = {
      TimeoutStartSec = 3000;
    };
    serviceConfig = {
      TimeoutSec = lib.mkForce 3000;
    };
    postStart = lib.mkAfter ''
      # set pw for the users
      $PSQL -c "ALTER ROLE grafana WITH PASSWORD '$(cat ${config.sops.secrets.postgres-borzoi-grafana-pw.path})';"
      $PSQL -c "ALTER ROLE borzoi WITH PASSWORD '$(cat ${config.sops.secrets.postgres-borzoi-pw.path})';"

      # fixup permissions
      # tlms is practically root, we need to FIXME something about it
      $PSQL -c "GRANT ALL ON DATABASE borzoi TO borzoi;"
      $PSQL -d borzoi -c "GRANT ALL ON ALL TABLES IN SCHEMA public TO borzoi;"
      $PSQL -d borzoi -c "GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO borzoi;"

      # Get graphana to SELECT from tables that might be interesting for it
      $PSQL -c "GRANT CONNECT ON DATABASE borzoi TO grafana;"
      $PSQL -d borzoi -c "GRANT SELECT ON ALL TABLES IN SCHEMA public TO grafana;"

      unset DATABASE_URL

      # borzoi setup
      export DATABASE_URL=postgres:///borzoi

      ${inputs.borzoi.packages.x86_64-linux.run-migration-borzoi}/bin/run-migration
      $PSQL -c "GRANT ALL ON DATABASE borzoi TO borzoi;"

      unset DATABASE_URL
    '';
  };
}
