/*
  This file contains the configuration for the gnuradio sdr decoding pipeline
*/

{ pkgs, config, lib, ... }:
let
  port = 8070;
in
{
  systemd = {
    services = {
      "clicky-bunty-server" = {
        enable = true;

        description = "dvbdump managment service";
        requires = [ "influxdb.service" ];
        after = [ "influxdb.service" ];
        wantedBy = [ "multi-user.target" ];

        script = ''
          export RUST_BACKTRACE=FULL
          export SALT_PATH=$(cat ${config.sops.secrets.postgres_password_hash_salt.path})
          export POSTGRES_PASSWORD=$(cat ${config.sops.secrets.postgres_password.path})
          exec ${pkgs.clicky-bunty-server}/bin/clicky-bunty-server --host 127.0.0.1 --port ${toString port}&
        '';

        environment = {
          "POSTGRES_HOST" = "127.0.0.1";
          "POSTGRES_PORT" = "5432";
        };

        serviceConfig = {
          Type = "forking";
          User = "clicky-bunty-server";
          Restart = "always";
        };
      };
      "pg-dvbdump-setup" = {
          description = "prepare dvbdump postgres database";
          wantedBy = [ "multi-user.target" ];
          after = [ "networking.target" "postgresql.service" ];
          serviceConfig.Type = "oneshot";

          path = [ pkgs.sudo config.services.postgresql.package ];
          script = ''
            sudo -u ${config.services.postgresql.superUser} psql -c "ALTER ROLE dvbdump WITH PASSWORD '$(cat ${config.sops.secrets.postgres_password.path})'"
          '';
      };
    };
  };

  services = {
    postgresql = {
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
    nginx = {
      enable = true;
      recommendedProxySettings = true;
      virtualHosts = {
        "management-backend.${config.dvb-dump.domain}" = {
          forceSSL = true;
          enableACME = true;
          locations = {
            "/" = {
              proxyPass = "http://127.0.0.1:${toString port}/";
              proxyWebsockets = true;
            };
          };
        };
      };
    };
  };

  # user accounts for systemd units
  users.users = {
    clicky-bunty-server = {
      name = "clicky-bunty-server";
      description = "";
      isNormalUser = true;
    };
  };

}
