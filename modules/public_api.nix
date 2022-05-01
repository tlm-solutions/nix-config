{ pkgs, config, lib, ... }: {
  systemd = {
    services = {
      "dvb-api" = {
        enable = true;
        wantedBy = [ "multi-user.target" ];

        script = "exec ${pkgs.dvb-api}/bin/dvb-api &"; 

        environment = {
          "GRPC_HOST" = "127.0.0.1:50051";
          "DEFAULT_WEBSOCKET_HOST" = "127.0.0.1:9001";
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
        "socket.dvb.solutions" = {
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
