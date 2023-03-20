{ config, ... }:
{
  TLMS.chemo = {
    enable = true;
    host = "0.0.0.0"; # this is the receiving grps part
    port = 8090;
    database = {
      host = "127.0.0.1";
      port = config.services.postgresql.port;
      passwordFile = config.sops.secrets.postgres_password.path;
      user = "tlms";
      database = "tlms";
    };
    GRPC = [
      {
        name = "API";
        host = config.TLMS.api.GRPC.host;
        port = config.TLMS.api.GRPC.port;
      }
      {
        name = "FUNNEL";
        host = config.TLMS.funnel.GRPC.host;
        port = config.TLMS.funnel.GRPC.port;
      }
    ];
  };
  systemd.services."chemo" = {
    after = [ "postgresql.service" ];
    wants = [ "postgresql.service" ];
  };
}
