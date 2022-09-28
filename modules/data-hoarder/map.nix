{ pkgs, config, ... }: {
  services = {
    nginx = {
      enable = true;
      recommendedProxySettings = true;
      virtualHosts = {
        "map.${config.deployment-dvb.domain}" = {
          forceSSL = true;
          enableACME = true;
          extraConfig = ''
            autoindex on;
          '';

          locations = {
            "/" = {
              root = if (config.deployment-dvb.domain == "dvb.solutions") then "${pkgs.windshield}/bin/" else "${pkgs.windshield-staging}/bin/";
              index = "index.html";
            };
            "~ \.(json)" = {
              root = "${pkgs.stops}/";
            };
          };
        };
      };
    };
  };
}
