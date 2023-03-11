{ config, ... }: {
  TLMS.datacare = {
    enable = true;
    host = "127.0.0.1";
    port = 8070;
    database = {
      host = "127.0.0.1";
      port = config.services.postgresql.port;
      user = "tlms";
      database = "tlms";
      passwordFile = config.sops.secrets.postgres_password.path;
    };
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
        "datacare.${config.deployment-TLMS.domain}" = {
          forceSSL = true;
          enableACME = true;
          locations = {
            "/" = {
              proxyPass = with config.TLMS.datacare; "http://${host}:${toString port}/";
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