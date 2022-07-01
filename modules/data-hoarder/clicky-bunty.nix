/*
  This file contains the configuration for the gnuradio sdr decoding pipeline
*/

{ pkgs, config, ... }:
let
  port = 8070;
in
{
  imports = [
    ./postgres.nix
  ];

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
          export SALT_PATH=${config.sops.secrets.postgres_password_hash_salt.path}
          export POSTGRES_PASSWORD=$(cat ${config.sops.secrets.postgres_password_dvbdump.path})
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

    };
  };

  services = {
    nginx = {
      enable = true;
      recommendedProxySettings = true;
      virtualHosts = {
        "management-backend.${config.dump-dvb.domain}" = {
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
      isSystemUser = true;
      group = config.users.groups.postgres-dvbdump.name;
    };
  };

}
