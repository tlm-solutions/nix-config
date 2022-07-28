{ pkgs, config, ... }: {
  services = {
    nginx = {
      enable = true;
      recommendedProxySettings = true;
      virtualHosts = {
        "map.${config.dump-dvb.domain}" = {
          forceSSL = true;
          enableACME = true;
          locations = {
            "/" = {
              root = if (config.dump-dvb.domain == "dvb.solutions") then "${pkgs.windshield}/bin/" else "${pkgs.windshield-staging}/bin/";
              index = "index.html";
            };
            "/stops/" = {
              root = "${pkgs.stops}/json/";
            };
          };
        };
      };
    };
  };
}
