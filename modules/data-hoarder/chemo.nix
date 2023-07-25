{ config, ... }:
let
  service_number = 3;
in {
  TLMS.chemo = {
    enable = true;
    host = "127.0.0.1";
    port = 50050 + service_number;
    database = {
      host = "127.0.0.1";
      port = config.services.postgresql.port;
      passwordFile = config.sops.secrets.postgres_password.path;
      user = "tlms";
      database = "tlms";
    };
    GRPC = [
      {
        name = "BUREAUCRAT";
        host = config.TLMS.bureaucrat.grpc.host;
        port = config.TLMS.bureaucrat.grpc.port;
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
