{ config, ... }:
let
  serice_number = 2;
in
{
  TLMS.funnel = {
    enable = true;
    GRPC = {
      host = "127.0.0.1";
      port = 50050 + serice_number;
    };
    defaultWebsocket = {
      host = "127.0.0.1";
      port = 9000 + serice_number;
    };
    metrics = {
      port = 9010;
      host = "0.0.0.0";
    };
    apiAddress = "127.0.0.1:${toString config.TLMS.api.port}";
  };
  services = {
    nginx = {
      enable = true;
      recommendedProxySettings = true;
      virtualHosts = {
        "socket.${config.deployment-TLMS.domain}" = {
          forceSSL = true;
          enableACME = true;
          locations = {
            "/" = {
              proxyPass = with config.TLMS.funnel.defaultWebsocket; "http://${host}:${toString port}/";
              proxyWebsockets = true;
            };
          };
        };
      };
    };
  };
}
