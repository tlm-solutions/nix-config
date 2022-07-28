{ pkgs, config, ... }: {
  dump-dvb.stopsJson = "${pkgs.stops}/json/stops.json";
  dump-dvb.graphJson = "${pkgs.stops}/json/graph.json";

  services = {
    nginx = {
      enable = true;
      recommendedProxySettings = true;
      virtualHosts = {
        "map.${config.dump-dvb.domain}" = {
          forceSSL = true;
          enableACME = true;
          extraConfig = ''
            autoindex on;
          '';

          locations = {
            "/" = {
              root = if (config.dump-dvb.domain == "dvb.solutions") then "${pkgs.windshield}/bin/" else "${pkgs.windshield-staging}/bin/";
              index = "index.html";
            };
            "/stops.json" = {
              root = "${pkgs.stops}/json";
            };
            "/graph.json" = {
              root = "${pkgs.stops}/json";
            };
          };
        };
      };
    };
  };
}
