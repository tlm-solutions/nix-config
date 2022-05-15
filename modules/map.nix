{ pkgs, config, lib, ... }: {
  services = {
    nginx = {
      enable = true;
      recommendedProxySettings = true;
      virtualHosts = {
        "map.${config.dvb-dump.domain}" = {
          forceSSL = true;
          enableACME = true;
          locations = {
            "/" = {
              root = if (config.dvb-dump.domain == "dvb.solutions") then "${pkgs.windshield}/bin/" else "${pkgs.windshield-staging}/bin/";
              index = "index.html";
            };
          };
        };
      };
    };
  };
}
