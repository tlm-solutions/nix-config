{ config, registry, ... }: {
  TLMS.dataAccumulator = {
    inherit (registry.port-data_accumulator) host port;
    enable = true;
    database = registry.postgres;
    GRPC = [{
      inherit (registry.grpc-data_accumulator-chemo) host port;
      name = "CHEMO";
    }];
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
        "dump.${
          (builtins.replaceStrings [ "tlm.solutions" ] [ "dvb.solutions" ]
            config.deployment-TLMS.domain)
        }" = {
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
              proxyPass = with registry.port-data_accumulator;
                "http://${host}:${toString port}/";
            };
          };
        };
      };
    };
  };

}
