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
  };

  services = {
    nginx = {
      enable = true;
      recommendedProxySettings = true;
      virtualHosts = {
        "api.${config.dump-dvb.domain}" = {
          forceSSL = true;
          enableACME = true;
          extraConfig = ''
            add_header Access-Control-Allow-Origin: *;
          '';
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
