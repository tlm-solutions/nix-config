{ config, ... }:
{
  dump-dvb.dataAccumulator = {
    enable = true;
    host = "0.0.0.0";
    port = 8080;
    DB = {
      backend = "POSTGRES";
      host = "127.0.0.1";
      port = 5432;
      telegramsPasswordFile = config.sops.secrets.postgres_password_telegrams.path;
      dvbPasswordFile = config.sops.secrets.postgres_password_dvbdump.path;
    };
    GRPC = [
      {
        name = "FUNNEL";
        host = "127.0.0.1";
        port = 50051;
      }
      {
        name = "API";
        host = "127.0.0.1";
        port = 9002;
      }
    ];
  };
}
