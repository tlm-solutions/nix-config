{
  services.postgresql = {
      port = 5432;
      enable = true;
      ensureUsers = [
        {
          name = "dvbdump";
          ensurePermissions = {
            "DATABASE dvbdump" = "ALL PRIVILEGES";
          };
        }
      ];
      ensureDatabases = [
        "dvbdump"
      ];
  };

  systemd."pg-dvbdump-setup" = {
      description = "prepare dvbdump postgres database";
      wantedBy = [ "multi-user.target" ];
      after = [ "networking.target" "postgresql.service" ];
      serviceConfig.Type = "oneshot";

      path = [ pkgs.sudo config.services.postgresql.package ];
      script = ''
        sudo -u ${config.services.postgresql.superUser} psql -c "ALTER ROLE dvbdump WITH PASSWORD '$(cat ${config.sops.secrets.postgres_password.path})'"
      '';
  };

}
