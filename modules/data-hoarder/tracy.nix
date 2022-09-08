{ config, ... }:
{
  dump-dvb.tracy = {
    enable = true;
    host = "0.0.0.0";
    port = 8060;
    database = {
      host = "127.0.0.1";
      port = config.services.postgresql.port;
      passwordFile = config.sops.secrets.postgres_password.path;
    };
  };
  systemd.services."tracy" = {
    after = [ "postgresql.service" ];
    wants = [ "postgresql.service" ];
  };
}
