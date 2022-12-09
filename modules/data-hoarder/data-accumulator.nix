{ config, ... }:
{
  dump-dvb.dataAccumulator = {
    enable = true;
    host = "0.0.0.0";
    port = 8080;
    database = {
      host = "127.0.0.1";
      port = config.services.postgresql.port;
      passwordFile = config.sops.secrets.postgres_password.path;
    };
    GRPC = [
      {
        name = "API";
        host = config.dump-dvb.api.GRPC.host;
        port = config.dump-dvb.api.GRPC.port;
      }
      {
        name = "FUNNEL";
        host = config.dump-dvb.funnel.GRPC.host;
        port = config.dump-dvb.funnel.GRPC.port;
      }
    ];
  };
  systemd.services."data-accumulator" = {
    after = [ "postgresql.service" ];
    wants = [ "postgresql.service" ];
  };

  services = {
    nginx = {
      enable = true;
      recommendedProxySettings = true;
      virtualHosts = {
        "dump.${config.deployment-dvb.domain}" = {
          forceSSL = true;
          enableACME = true;
          locations = {
            "/" = {
              proxyPass = with config.dump-dvb.dataAccumulator; "http://${host}:${toString port}/";
            };
          };
        };
      };
    };
  };

}
