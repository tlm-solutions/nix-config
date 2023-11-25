{ config, registry, ... }: {
  TLMS.trekkie = {
    inherit (registry.port-trekkie) host port;
    enable = true;
    saltPath = config.sops.secrets.postgres_password_hash_salt.path;
    database = registry.postgres;
    redis = registry.redis-trekkie;
    grpc = registry.grpc-trekkie-chemo;
    logLevel = "info";
  };
  systemd.services."trekkie" = {
    after = [ "postgresql.service" ];
    wants = [ "postgresql.service" ];
  };

  services = {
    redis.servers."trekkie" = with registry.redis-trekkie; {
      inherit port;
      enable = true;
      bind = host;
    };

    nginx = {
      enable = true;
      recommendedProxySettings = true;
      virtualHosts = {
        "trekkie.${
          (builtins.replaceStrings [ "tlm.solutions" ] [ "dvb.solutions" ]
            config.deployment-TLMS.domain)
        }" = {
          enableACME = true;
          forceSSL = true;
          extraConfig = ''
            rewrite ^ https://trekkie.${config.deployment-TLMS.domain}$request_uri permanent;
          '';
        };
        "trekkie.${config.deployment-TLMS.domain}" = {
          forceSSL = true;
          enableACME = true;
          locations = {
            "/" = {
              proxyPass = with registry.port-trekkie;
                "http://${host}:${toString port}/";
            };
          };
        };
      };
    };
  };
}
