{ config, ... }: {
  dump-dvb.clickyBuntyServer = {
    enable = true;
    host = "127.0.0.1";
    port = 8070;
    postgresHost = "127.0.0.1";
    postgresPort = config.services.postgresql.port;
    postgresPasswordFile = config.sops.secrets.postgres_password_dvbdump.path;
    saltFile = config.sops.secrets.postgres_password_hash_salt.path;
    user = "clicky-bunty-server";
    group = config.users.groups.postgres-dvbdump.name;
  };

  services = {
    nginx = {
      enable = true;
      recommendedProxySettings = true;
      virtualHosts = {
        "management-backend.${config.dump-dvb.domain}" = {
          forceSSL = true;
          enableACME = true;
          locations = {
            "/" = {
              proxyPass = with config.dump-dvb.clickyBuntyServer; "http://${host}:${toString port}/";
              proxyWebsockets = true;
            };
          };
        };
      };
    };
  };
}
