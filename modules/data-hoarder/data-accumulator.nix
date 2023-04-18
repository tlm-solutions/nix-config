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
        name = "CHEMO";
        host = config.TLMS.chemo.host;
        port = config.TLMS.chemo.port;
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
        "dump.${(builtins.replaceStrings [ "tlm.solutions" ] [ "dvb.solutions" ] config.deployment-TLMS.domain)}" = {
          enableACME = true;
          forceSSL = true;
          extraConfig = ''
            rewrite ^ https://dump.${config.deployment-TLMS.domain}$request_uri permanent;
          '';
        };
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
