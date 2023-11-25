{ config, registry, ... }: {
  TLMS.chemo = {
    inherit (registry.grpc-data_accumulator-chemo) host port;
    enable = true;
    database = {
      host = "127.0.0.1";
      port = config.services.postgresql.port;
      passwordFile = config.sops.secrets.postgres_password.path;
      user = "tlms";
      database = "tlms";
    };
    GRPC = [
      {
        inherit (registry.grpc-chemo-bureaucrat) host port;
        name = "BUREAUCRAT";
      }
      {
        inherit (registry.grpc-chemo-funnel) host port;
        name = "FUNNEL";
      }
    ];
  };
  systemd.services."chemo" = {
    after = [ "postgresql.service" ];
    wants = [ "postgresql.service" ];
  };
}
