{ config, registry, ... }: {
  TLMS.lizard = {
    enable = true;
    http = { inherit (registry.port-lizard) host port; };

    redis = registry.redis-bureaucrat-lizard;
    logLevel = "debug";
    workerCount = 6;
  };

  services = {
    nginx = {
      enable = true;
      recommendedProxySettings = true;
      virtualHosts = {
        "lizard.${
          (builtins.replaceStrings [ "tlm.solutions" ] [ "dvb.solutions" ]
            config.deployment-TLMS.domain)
        }" = {
          enableACME = true;
          forceSSL = true;
          extraConfig = ''
            rewrite ^ https://lizard.${config.deployment-TLMS.domain}$request_uri permanent;
          '';
        };
        "lizard.${config.deployment-TLMS.domain}" = {
          forceSSL = true;
          enableACME = true;
          locations = {
            "/" = {
              proxyPass = with registry.port-lizard;
                "http://${host}:${toString port}/";
              proxyWebsockets = true;
            };
          };
        };
      };
    };
  };
}
