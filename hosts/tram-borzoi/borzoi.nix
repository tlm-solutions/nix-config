{ config, ... }:
let
  borzoi-port = 8080;
in
{
  networking.firewall.allowedTCPPorts = [ borzoi-port ];

  TLMS.borzoi = {
    enable = true;
    http = {
      host = "0.0.0.0";
      port = borzoi-port;
    };
    database = {
      host = "127.0.0.1";
      port = config.services.postgresql.port;
      passwordFile = config.sops.secrets.postgres-borzoi-pw.path;
      user = "borzoi";
      database = "borzoi";
    };
  };

  systemd.services."borzoi" = {
    after = [ "postgresql.service" ];
    wants = [ "postgresql.service" ];
  };

}
