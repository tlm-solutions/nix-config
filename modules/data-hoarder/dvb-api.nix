{ config, ... }:
let
  service_number = 1;
in
{
  TLMS.api = {
    enable = true;
    GRPC = {
      host = "127.0.0.1";
      port = 50050 + service_number;
    };

    port = 9000 + service_number;
    graphFile = config.TLMS.graphJson;
    stopsFile = config.TLMS.stopsJson;
    workerCount = 6;
  };

  services = {
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
