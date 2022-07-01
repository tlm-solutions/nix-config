{ pkgs, config, lib, ... }: {
  systemd = {
    services = {
      "funnel" = {
        enable = true;
        wantedBy = [ "multi-user.target" ];

        script = "exec ${pkgs.funnel}/bin/funnel &";

        environment = {
          "GRPC_HOST" = "127.0.0.1:50052";
          "DEFAULT_WEBSOCKET_HOST" = "127.0.0.1:9001";
          "GRAPH_FILE" = "${config.dump-dvb.graphJson}";
          "STOPS_FILE" = "${config.dump-dvb.stopsJson}";
        };

        serviceConfig = {
          Type = "forking";
          User = "funnel";
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
        "socket.${config.dump-dvb.domain}" = {
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
    funnel = {
      name = "funnel";
      description = "public websocket serive";
      isNormalUser = true;
      extraGroups = [ ];
    };
  };
}
