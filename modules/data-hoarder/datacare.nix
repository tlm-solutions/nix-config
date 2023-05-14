{ config, ... }: {
  TLMS.datacare = {
    enable = true;
    http = {
      host = "127.0.0.1";
      port = 8070;
    };
    database = {
      host = "127.0.0.1";
      port = config.services.postgresql.port;
      user = "tlms";
      database = "tlms";
      passwordFile = config.sops.secrets.postgres_password.path;
    };
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
        "datacare.${(builtins.replaceStrings [ "tlm.solutions" ] [ "dvb.solutions" ] config.deployment-TLMS.domain)}" = {
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
              proxyPass = with config.TLMS.datacare.http; "http://${host}:${toString port}/";
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
