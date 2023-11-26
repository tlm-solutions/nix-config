{ config, registry, ... }: {
  TLMS.funnel = {
    enable = true;
    GRPC = registry.grpc-chemo-funnel;
    defaultWebsocket = { inherit (registry.port-funnel) host port; };
    metrics = {
      inherit (registry.port-funnel-metrics) port;
      host = registry.wgAddr4;
    };
  };
  services = {
    nginx = {
      enable = true;
      recommendedProxySettings = true;
      virtualHosts = {
        "socket.${
          (builtins.replaceStrings [ "tlm.solutions" ] [ "dvb.solutions" ]
            config.deployment-TLMS.domain)
        }" = {
          enableACME = true;
          forceSSL = true;
          locations."/" = {
            proxyWebsockets = true;
            proxyPass = with registry.port-funnel;
              "http://${host}:${toString port}/";
          };
        };
        "socket.${config.deployment-TLMS.domain}" = {
          forceSSL = true;
          enableACME = true;
          locations = {
            "/" = {
              proxyPass = with registry.port-funnel;
                "http://${host}:${toString port}/";
              proxyWebsockets = true;
            };
          };
        };
      };
    };
  };
}
