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
        requires = [ "influxdb.service" ];
        after = [ "influxdb.service" ];
        wantedBy = [ "multi-user.target" ];

        script = ''
          exec ${pkgs.clicky-bunty-server}/bin/clicky-bunty-server --host 127.0.0.1 --port ${toString port}&
        '';

        environment = {
          "POSTGRES" = "postgresql://dvbdump@localhost:5432";
          "SALT_PATH" = "/root/password_hash_salt"; #TODO: do it proper with sops
        };
        serviceConfig = {
          Type = "forking";
          User = "clicky-bunty-server";
          Restart = "always";
        };
      };
    };
  };

  services = {
    postgresql = {
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
        "managment-backend.${config.dvb-dump.domain}" = {
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
