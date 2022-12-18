{ config, ... }:
let
  service_number = 1;
in
{
  dump-dvb.api = {
    enable = true;
    GRPC = {
      host = "127.0.0.1";
      port = 50050 + service_number;
    };

    port = 9000 + service_number;
    graphFile = config.dump-dvb.graphJson;
    stopsFile = config.dump-dvb.stopsJson;
    workerCount = 6;
  };

  services = {
    nginx = {
      enable = true;
      recommendedProxySettings = true;
      virtualHosts = {
        "api.${config.deployment-dvb.domain}" = {
          forceSSL = true;
          enableACME = true;
          locations = {
            "/" = {
              proxyPass = with config.dump-dvb.api; "http://127.0.0.1:${toString port}/";
              proxyWebsockets = true;
            };
          };
        };
      };
    };
  };
}
