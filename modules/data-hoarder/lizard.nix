{ config, ... }:
let
  service_number = 1;
in
{
  TLMS.lizard = {
    enable = true;
    http = {
      host = "127.0.0.1";
      port = 9000 + service_number;
    };
 
    redis = {
      http = config.services.redis.servers."state".bind;
      port = config.services.redis.servers."state".port;
    };

    workerCount = 6;
  };

  services = {
    redis.servers."state" = {
      enable = true;
      bind = "127.0.0.1";
      port = 5314; 
    };
    nginx = {
      enable = true;
      recommendedProxySettings = true;
      virtualHosts = {
        "api.${config.deployment-TLMS.domain}" = {
          forceSSL = true;
          enableACME = true;
          locations = {
            "/" = {
              proxyPass = with config.TLMS.api; "http://127.0.0.1:${toString port}/";
              proxyWebsockets = true;
            };
          };
        };
      };
    };
  };
}
