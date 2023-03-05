{ config, ... }:
{
  TLMS.dataAccumulator = {
    enable = true;
    host = "0.0.0.0";
    port = 8080;
    database = {
      host = "127.0.0.1";
      port = config.services.postgresql.port;
      passwordFile = config.sops.secrets.postgres_password.path;
      user = "tlms";
      database = "tlms";
    };
    GRPC = [
      {
        name = "API";
        host = config.TLMS.api.GRPC.host;
        port = config.TLMS.api.GRPC.port;
      }
      {
        name = "FUNNEL";
        host = config.TLMS.funnel.GRPC.host;
        port = config.TLMS.funnel.GRPC.port;
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
        "dump.${config.deployment-TLMS.domain}" = {
          forceSSL = true;
          enableACME = true;
          locations = {
            "/" = {
              proxyPass = with config.TLMS.dataAccumulator; "http://${host}:${toString port}/";
            };
          };
        };
      };
    };
  };

}
