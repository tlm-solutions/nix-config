{ config, registry, ... }: {
  TLMS.chemo = {
    inherit (registry.grpc-data_accumulator-chemo) host port;
    enable = true;
    database = registry.postgres;
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
