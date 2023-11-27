{ config, registry, ... }:
{
  networking.firewall.allowedTCPPorts = [ registry.port-borzoi.port ];

  TLMS.borzoi = {
    enable = true;
    http = registry.port-borzoi;
    database = registry.postgres;
  };

  users.users.borzoi = {
    isSystemUser = true;
  };
  users.groups.borzoi = {
    members = [ config.users.users.borzoi.name ];
  };

  systemd.services."borzoi" = {
    after = [ "postgresql.service" ];
    wants = [ "postgresql.service" ];
    serviceConfig = {
      User = config.users.users.borzoi.name;
      Group = config.users.groups.borzoi.name;
    };
  };

}
