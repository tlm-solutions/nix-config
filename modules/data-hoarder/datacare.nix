{ config, registry, ... }: {
  TLMS.datacare = {
    enable = true;
    http = registry.port-datacare;
    database = registry.postgres;
    allowedIpsExport = [ "10.13.37.0/24" ];
    saltFile = config.sops.secrets.postgres_password_hash_salt.path;
    user = "datacare";
    group = config.users.groups.postgres-tlms.name;
  };
  systemd.services."datacare" = {
    after = [ "postgresql.service" ];
    wants = [ "postgresql.service" ];
  };

  services = {
    nginx = {
      enable = true;
      recommendedProxySettings = true;
      virtualHosts = {
        "datacare.${
          (builtins.replaceStrings [ "tlm.solutions" ] [ "dvb.solutions" ]
            config.deployment-TLMS.domain)
        }" = {
          enableACME = true;
          forceSSL = true;
          extraConfig = ''
            rewrite ^ https://datacare.${config.deployment-TLMS.domain}$request_uri permanent;
          '';
        };
        "datacare.${config.deployment-TLMS.domain}" = {
          forceSSL = true;
          enableACME = true;
          locations = {
            "/" = {
              proxyPass = with registry.port-data_accumulator;
                "http://${host}:${toString port}/";
              proxyWebsockets = true;
              extraConfig = ''
                more_set_headers "Access-Control-Allow-Credentials: true";
              '';
            };
          };
        };
      };
    };
  };
}
