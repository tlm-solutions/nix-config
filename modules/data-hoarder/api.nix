{ pkgs, config, ... }: {
  systemd = {
    services = {
      "dvb-api" = {
        enable = true;
        wantedBy = [ "multi-user.target" ];

        script = "exec ${pkgs.dvb-api}/bin/dvb-api &";

        environment = {
          "GRPC_HOST" = "127.0.0.1:50051";
          "HTTP_PORT" = "9001";
          "GRAPH_FILE" = "${config.dump-dvb.graphJson}";
          "STOPS_FILE" = "${config.dump-dvb.stopsJson}";
        };

        serviceConfig = {
          Type = "forking";
          User = "dvb-api";
          Restart = "always";
        };
      };
    };
  };

  services = {
    nginx = {
      enable = true;
      recommendedProxySettings = true;
      virtualHosts = {
        "api.${config.dump-dvb.domain}" = {
          forceSSL = true;
          enableACME = true;
          locations = {
            "/" = {
              proxyPass = "http://127.0.0.1:9001/";
              proxyWebsockets = true;
            };
          };
        };
      };
    };
  };

  # user accounts for systemd units
  users.users = {
    dvb-api = {
      name = "dvb-api";
      description = "public dvb api serive";
      isNormalUser = true;
      extraGroups = [ ];
    };
  };
}
