{ config, ... }:
{
  dump-dvb.dataAccumulator = {
    enable = true;
    host = "0.0.0.0";
    port = 8080;
    database = {
      host = "127.0.0.1";
      port = config.services.postgresql.port;
      passwordFile = config.sops.secrets.postgres_password.path;
    };
    GRPC = [
      {
        name = "FUNNEL";
        host = config.dump-dvb.funnel.GRPC.host;
        port = config.dump-dvb.funnel.GRPC.port;
      }
      {
        name = "API";
        host = config.dump-dvb.api.GRPC.host;
        port = config.dump-dvb.api.GRPC.port;
      }
    ];
  };
  systemd.services."data-accumulator" = {
    after = [ "postgresql.service" ];
    wants = [ "postgresql.service" ];
  };
}
