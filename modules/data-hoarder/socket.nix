{ pkgs, config, ... }: {
  dump-dvb.funnel = {
    enable = true;
    GRPC = {
      host = "127.0.0.1";
      port = 9002;
    };
    defaultWebsocket = {
      host = "127.0.0.1";
      port = 50052;
    };
  };
  services = {
    nginx = {
      enable = true;
      recommendedProxySettings = true;
      virtualHosts = {
        "socket.${config.dump-dvb.domain}" = {
          forceSSL = true;
          enableACME = true;
          locations = {
            "/" = {
              proxyPass = with config.dump-dvb.funnel.GRPC; "http://${host}:${toString port}/";
              proxyWebsockets = true;
            };
          };
        };
      };
    };
  };
}
