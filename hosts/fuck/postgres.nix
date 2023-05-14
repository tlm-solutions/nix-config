{ inputs, ... }: {
  services.postgresql = {
    enable = true;
    port = 5432;
    package = pkgs.postgresql_14;
    ensureDatabases = [ "tlms" ];
    ensureUsers = [
      {
        name = "tlms";
        ensurePermissions = {
          "DATABASE tlms" = "ALL PRIVILEGES";
          "ALL TABLES IN SCHEMA public" = "ALL";
        };
      }
    ];
  };

  environment.systemPackages = [ inputs.tlms-rs.packages.x86_64-linux.run-migration-based ];

  systemd.services.postgresql = {
    unitConfig = {
      TimeoutStartSec = 3000;
    };
    serviceConfig = {
      TimeoutSec = lib.mkForce 3000;
    };
    postStart = lib.mkAfter ''
      $PSQL -c "ALTER ROLE tlms WITH PASSWORD '$(cat ${inputs.self}/tests/vm/test-pw)';"

      export DATABASE_URL=postgres:///tlms
      ${inputs.tlms-rs.packages.x86_64-linux.run-migration-based}/bin/run-migration

      # fix the permissions for tlms user on migration-created tables
      $PSQL -c "GRANT ALL ON DATABASE tlms TO tlms;"
      $PSQL -d tlms -c "GRANT ALL ON ALL TABLES IN SCHEMA public TO tlms;"
      $PSQL -d tlms -c "GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO tlms;"
      unset DATABASE_URL
    '';
  };

}
