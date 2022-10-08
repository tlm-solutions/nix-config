{ config, ... }:
{
  dump-dvb.trekkie = {
    enable = true;
    host = "0.0.0.0";
    saltPath = config.sops.secrets.postgres_password_hash_salt.path;
    port = 8060;
    database = {
      host = "127.0.0.1";
      port = config.services.postgresql.port;
      passwordFile = config.sops.secrets.postgres_password.path;
    };
    logLevel = "info";
  };
  systemd.services."trekkie" = {
    after = [ "postgresql.service" ];
    wants = [ "postgresql.service" ];
  };

  services = {
    nginx = {
      enable = true;
      recommendedProxySettings = true;
      virtualHosts = {
        "trekkie.${config.deployment-dvb.domain}" = {
          forceSSL = true;
          enableACME = true;
          locations = {
            "/" = {
              proxyPass = with config.dump-dvb.trekkie; "http://${host}:${toString port}/";
            };
          };
        };
      };
    };
  };


}
